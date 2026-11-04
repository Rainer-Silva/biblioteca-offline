"""Camada de compatibilidade macOS para a Biblioteca Offline (não altera nenhum arquivo do Windows).

O app e os baixadores foram escritos para Windows. Em vez de editar o código original (os dois sistemas
usam o mesmo SSD), este módulo é carregado ANTES deles e ajusta, em memória:
  - subprocess: ignora creationflags (só existe no Windows); troca 'curl.exe' por 'curl', o Python
    embutido do Windows (Programas/Python/python.exe) pelo python3 do Mac, e 'X.exe' por 'X' quando só a
    versão Mac existe; 'taskkill' vira um kill do grupo de processos.
  - sistema.achar: procurando 'kiwix-serve.exe' / 'llama-server.exe' / 'kiwix-manage.exe', acha antes as
    versões Mac (Programas/KiwixServe/macos, Programas/LlamaCpp/macos) ou as do Homebrew (PATH).
  - sistema.memoria / nucleos_*: lidos com sysctl / vm_stat.
  - sistema.preparar_runtime: não copia DLLs do Visual C++ para pastas Mac.
  - processos filhos: encerrados quando o app fecha (no Windows isso é feito por um Job Object).
macOS compatibility shim: loaded before the original Python code, patches it in memory only.
"""
import atexit
import glob
import os
import shutil
import signal
import subprocess
import sys

POSIX = os.name != 'nt'
_Popen_original = subprocess.Popen
_filhos = []
RODAR = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'rodar.py')


def _so_mac_existe(arg):
    if not isinstance(arg, str) or not arg.lower().endswith('.exe'):
        return arg
    base = os.path.basename(arg).lower()
    if base == 'curl.exe':
        return shutil.which('curl') or 'curl'
    if base in ('python.exe', 'pythonw.exe') and 'programas' in arg.lower():
        return sys.executable
    sem = arg[:-4]
    if os.path.isfile(sem):
        return sem
    mac = os.path.join(os.path.dirname(arg), 'macos', os.path.basename(sem))
    if os.path.isfile(mac):
        return mac
    achado = shutil.which(os.path.basename(sem))
    return achado or arg


class _PopenMac(_Popen_original):
    def __init__(self, args, *a, **kw):
        if POSIX:
            kw.pop('creationflags', None)
            if len(a) >= 12:   # creationflags posicional (raro)
                a = list(a)
                a[11] = 0
            if isinstance(args, (list, tuple)) and args:
                args = [_so_mac_existe(x) for x in args]
                # filhos Python (baixadores chamados pelo instalador/atualizador) também recebem esta camada
                if args[0] == sys.executable and RODAR not in args:
                    for i, x in enumerate(args):
                        if isinstance(x, str) and x.endswith('.py'):
                            args = args[:i] + [RODAR] + args[i:]
                            break
                if args[0] == 'taskkill':   # taskkill /T /F /PID n
                    try:
                        pid = int(args[-1])
                        try:
                            os.killpg(os.getpgid(pid), signal.SIGTERM)
                        except Exception:
                            os.kill(pid, signal.SIGTERM)
                    except Exception:
                        pass
                    args = ['true']
        super().__init__(args, *a, **kw)
        _filhos.append(self)


def _matar_filhos(*_):
    for p in list(_filhos):
        try:
            if p.poll() is None:
                p.terminate()
        except Exception:
            pass


def aplicar_subprocess():
    if not POSIX:
        return
    subprocess.Popen = _PopenMac
    atexit.register(_matar_filhos)
    for s in (signal.SIGHUP, signal.SIGTERM):
        try:
            signal.signal(s, lambda *_: (_matar_filhos(), os._exit(0)))
        except Exception:
            pass


def _sysctl(nome):
    try:
        return int(subprocess.run(['sysctl', '-n', nome], capture_output=True, text=True, timeout=5).stdout.strip())
    except Exception:
        return 0


def _memoria_mac():
    total = _sysctl('hw.memsize')
    livre = 0
    try:
        out = subprocess.run(['vm_stat'], capture_output=True, text=True, timeout=5).stdout
        pag = 4096
        vals = {}
        for linha in out.splitlines():
            if 'page size of' in linha:
                pag = int(''.join(c for c in linha.split('page size of')[1] if c.isdigit()) or 4096)
            elif ':' in linha:
                k, v = linha.split(':', 1)
                v = v.strip().rstrip('.')
                if v.isdigit():
                    vals[k.strip()] = int(v)
        livre = (vals.get('Pages free', 0) + vals.get('Pages inactive', 0) + vals.get('Pages speculative', 0)
                 + vals.get('Pages purgeable', 0)) * pag
    except Exception:
        pass
    return (total, livre)


def aplicar_app(sistema):
    """Chamado depois de importar App/biblioteca/sistema.py."""
    if not POSIX:
        return
    achar_original = sistema.achar

    def achar(padrao_rel):
        if '.exe' not in padrao_rel.lower():
            return achar_original(padrao_rel)
        sem = padrao_rel[:-4] if padrao_rel.lower().endswith('.exe') else padrao_rel.replace('.exe', '')
        nome = os.path.basename(sem)
        achados = [p for p in achar_original(sem)
                   if os.path.isfile(p) and not p.endswith(('.ok', '.exe', '.part')) and os.access(p, os.X_OK)]
        if not achados and '*' not in nome:
            w = shutil.which(nome)   # Homebrew: brew install kiwix-tools llama.cpp
            if w:
                achados = [w]
        return achados

    sistema.achar = achar
    if sys.platform == 'darwin':
        sistema.memoria = _memoria_mac
        sistema.nucleos_fisicos = lambda: _sysctl('hw.physicalcpu') or max(1, (os.cpu_count() or 2) // 2)
        sistema.nucleos_rapidos = lambda: (_sysctl('hw.perflevel0.physicalcpu') or sistema.nucleos_fisicos())
    sistema.preparar_runtime = lambda exe: None
    sistema.preparar_runtime_kiwix = lambda exe: None


def aplicar_kiwix(kiwix):
    """kiwix._library_xml procura kiwix-manage.exe ao lado do kiwix-serve: no Mac é 'kiwix-manage'."""
    if not POSIX:
        return
    original = kiwix._library_xml

    def _library_xml(exe, zims):
        manage = os.path.join(os.path.dirname(exe), 'kiwix-manage')
        if os.path.isfile(manage):
            ponte = os.path.join(os.path.dirname(exe), 'kiwix-manage.exe')
            # o original testa os.path.exists(...manage.exe); simulamos só para esta chamada
            exists = os.path.exists
            os.path.exists = lambda p: True if p == ponte else exists(p)
            try:
                return original(exe, zims)
            finally:
                os.path.exists = exists
        return original(exe, zims)

    kiwix._library_xml = _library_xml


_ = glob  # (mantido para quem estender)
