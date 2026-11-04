# Biblioteca Offline no macOS / on macOS

> Port não oficial para macOS (Apple Silicon e Intel) do kit [brenobernardes25-afk/biblioteca-offline](https://github.com/brenobernardes25-afk/biblioteca-offline) (release `v2026-10-30`).
> Os arquivos do Windows **não foram alterados**: o mesmo SSD funciona no Windows e no Mac.
> Unofficial macOS port. Windows files are **untouched**; one SSD works on both.

---

## Português

### Do que precisa
- Mac com macOS 12 ou mais novo, Apple Silicon (M1–M4) ou Intel.
- **SSD de 1 TB no mínimo (2 TB recomendado)**. A biblioteca tem ≈ 821 GB + ≈ 6 GB gerados.
- Formato do SSD: **exFAT** (lê e grava no Mac e no Windows). **Não use FAT32** (limite de 4 GB por arquivo) nem NTFS (somente leitura no Mac). APFS funciona, mas só no Mac.
  Formatar: Utilitário de Disco → Apagar → Formato "ExFAT", Esquema "Mapa de Partição GUID". (Isso apaga o SSD.)
- **Python 3.9+** com SQLite FTS5: `brew install python` (https://brew.sh) ou o instalador oficial em https://www.python.org/downloads/macos/.
- Internet e tempo (horas a dias). `curl` já vem no macOS. Não precisa de `sudo`.

### Passo a passo
1. Baixe `Kit_Biblioteca_Offline_2026-10-30.zip` da release original e descompacte **inteiro** na raiz do SSD (devem aparecer `App`, `_Baixador`, `Programas`...).
2. Copie a pasta **`mac`** deste repositório para dentro da raiz do SSD (ao lado de `App`).
3. **Gatekeeper / quarentena:** arquivos baixados pelo navegador ficam marcados e o macOS bloqueia scripts. Abra o Terminal e rode (troque o nome do volume):
   ```bash
   xattr -dr com.apple.quarantine "/Volumes/NOME_DO_SSD/mac"
   chmod +x "/Volumes/NOME_DO_SSD/mac/"*.command   # em exFAT não faz diferença
   ```
   Alternativa: clique com o botão direito em `instalar_biblioteca.command` → **Abrir** → **Abrir**. Em exFAT o macOS pode não guardar a marca de quarentena; mesmo assim, se aparecer "não pode ser aberto", use o comando acima.
4. Dois cliques em **`mac/instalar_biblioteca.command`**. Ele:
   - confere o formato do SSD e o espaço livre;
   - baixa as versões **Mac** do `kiwix-serve` e do `llama-server` (binários oficiais, para o seu processador);
   - roda o instalador original (mesma lista de arquivos, mesma ordem de prioridade, **retomável**: se parar, rode de novo);
   - impede o Mac de dormir enquanto baixa (`caffeinate`).
   Ver o que falta sem baixar: no Terminal, `"/Volumes/NOME_DO_SSD/mac/instalar_biblioteca.command" --verificar`.
5. Quando aparecer **PRONTO**, dois cliques em **`mac/abrir_biblioteca.command`**. O navegador abre em `http://127.0.0.1:8800`. Para sair, feche a janela do Terminal.

### Trocas de programas do Windows (.exe) por equivalentes Mac
| Windows (kit) | macOS (este port) |
|---|---|
| `Programas/Python/python.exe` (Python 3.12 embutido) | Python 3 do Homebrew ou python.org |
| `curl.exe` | `/usr/bin/curl` (vem no macOS) |
| `kiwix-serve.exe`, `kiwix-manage.exe` (kiwix-tools 3.8.1 win) | `kiwix-tools_macos-arm64/x86_64-3.8.1` oficiais → `Programas/KiwixServe/macos/` (ou `brew install kiwix-tools`) |
| `llama-server.exe` (llama.cpp b11889 win-cpu) | `llama-b11889-bin-macos-arm64/x64` oficiais → `Programas/LlamaCpp/macos/` (usa a GPU Metal no Apple Silicon; ou `brew install llama.cpp`) |
| DLLs do Visual C++ (`App/runtime`) | não são necessárias |
| `kiwix-desktop_windows` | App Kiwix para macOS (App Store / https://kiwix.org) — opcional |
| `Firefox_Instalador.exe`, `GPXSee_Instalador.exe` | versões Mac em mozilla.org e gpxsee.org — opcional |
| OCR do Windows (`ocr_windows.ps1`, PowerShell) | **sem equivalente**; o OCR no navegador (Tesseract.js do app) continua funcionando |

O código Python original **não foi editado**: `mac/lib/mac_compat.py` ajusta em memória o que é específico do Windows (nomes `.exe`, `creationflags`, `taskkill`, memória/núcleos via `sysctl`, encerrar processos filhos ao fechar).

### Limitações
- O **OCR em lote de PDFs escaneados** usa o OCR do Windows: no Mac esses PDFs não entram na busca por texto (o resto da busca funciona).
- A "Atualizar pela internet" do app chama o atualizador original; deve funcionar com a camada Mac, mas não foi testada num Mac.
- Os instaladores Windows/Android em `6_Instaladores` continuam sendo baixados (servem para usar o SSD no Windows/celular).
- Testado só em Linux (servidor do app em 127.0.0.1:8800 sobe, instalador `--verificar` roda); **não foi testado num Mac real**.

---

## English

### Requirements
- macOS 12+, Apple Silicon or Intel.
- **SSD ≥ 1 TB (2 TB recommended)**; the library is ≈ 821 GB plus ≈ 6 GB generated.
- Format **exFAT** (Mac + Windows). **Not FAT32** (4 GB file limit), not NTFS (read-only on macOS). APFS works Mac-only.
- **Python 3.9+** with SQLite FTS5: `brew install python` or the python.org installer.
- Internet and time. No `sudo` needed.

### Steps
1. Download `Kit_Biblioteca_Offline_2026-10-30.zip` from the original release and unzip it **entirely** to the SSD root.
2. Copy this repo's **`mac`** folder into the SSD root (next to `App`).
3. **Gatekeeper / quarantine:** browser-downloaded files are flagged and macOS blocks the scripts. In Terminal:
   ```bash
   xattr -dr com.apple.quarantine "/Volumes/YOUR_SSD/mac"
   chmod +x "/Volumes/YOUR_SSD/mac/"*.command
   ```
   Or right-click `instalar_biblioteca.command` → **Open** → **Open**.
4. Double-click **`mac/instalar_biblioteca.command`**: checks volume format and free space, downloads the official macOS `kiwix-serve` and `llama-server` for your CPU, then runs the original installer (same manifest and priority order, **resumable**: just run it again). Keeps the Mac awake with `caffeinate`. Use `--verificar` to list what is missing without downloading.
5. When it says **PRONTO**, double-click **`mac/abrir_biblioteca.command`**. The browser opens `http://127.0.0.1:8800`. Close the Terminal window to quit.

### Windows → macOS replacements
See the table above: embedded Python → Homebrew/python.org Python; `curl.exe` → system curl; kiwix-tools win → official kiwix-tools macOS 3.8.1; llama.cpp win → official llama.cpp b11889 macOS (Metal on Apple Silicon); VC++ DLLs → not needed; Windows OCR → no equivalent (in-browser Tesseract.js OCR still works). Original Python code is not modified; `mac/lib/mac_compat.py` patches Windows-only bits in memory.

### Limitations
- Batch OCR of scanned PDFs relies on Windows OCR, so on a Mac those PDFs aren't text-searchable.
- In-app "update from internet" should work through the shim but is untested on a Mac.
- Windows/Android installers in `6_Instaladores` are still downloaded (useful for Windows/phones).
- Tested only on Linux (app server starts on 127.0.0.1:8800, installer `--verificar` runs). **Not yet tested on a real Mac.**

### Security notes (static review of the original kit, 2026-11-04)
- `Programas/Python/*` is byte-identical to the official `python-3.12.7-embed-amd64.zip` from python.org (all 35 files).
- No obfuscation, encoded commands, persistence (Run keys, scheduled tasks, Startup) or self-updating code found. Download hosts are public sources (kiwix.org, huggingface.co, github.com, embrapa.br, eb.mil.br, archive.org, hesperian.org, organicmaps.app, mapsforge.org, python.org, mozilla.org, sourceforge.net, ...).
- The VC++ runtime DLLs in `App/runtime` were not hash-verified against Microsoft's redistributable.
- The author's GitHub account is new. Scan the zip before use anyway.
