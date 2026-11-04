"""Executa um script da biblioteca com a camada macOS aplicada.
Uso: python3 mac/lib/rodar.py app [args]        -> App/main.py
     python3 mac/lib/rodar.py script.py [args]  -> qualquer script (instalador, baixadores)
"""
import os
import runpy
import sys

AQUI = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, AQUI)
import mac_compat  # noqa: E402

mac_compat.aplicar_subprocess()
alvo = sys.argv[1]
raiz = os.environ.get('BIBLIOTECA_RAIZ') or os.getcwd()
if alvo == 'app':
    app = os.path.join(raiz, 'App')
    sys.path.insert(0, app)
    sys.path.insert(1, os.path.join(app, 'vendor'))
    from biblioteca import sistema, kiwix  # noqa: E402
    mac_compat.aplicar_app(sistema)
    mac_compat.aplicar_kiwix(kiwix)
    _system = os.system
    os.system = lambda c: 0 if str(c).startswith('title ') else _system(c)   # 'title' é do cmd.exe
    alvo = os.path.join(app, 'main.py')
else:
    sys.path.insert(0, os.path.dirname(os.path.abspath(alvo)))
sys.argv = [alvo] + sys.argv[2:]
runpy.run_path(alvo, run_name='__main__')
