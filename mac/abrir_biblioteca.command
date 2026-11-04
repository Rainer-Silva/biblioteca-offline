#!/bin/bash
# BIBLIOTECA OFFLINE — abrir no macOS (equivalente ao ABRIR_BIBLIOTECA.bat)
# Sobe o app em http://127.0.0.1:8800 (kiwix-serve em 8801, IA llama-server sob demanda) e abre o navegador.
# Para sair: feche esta janela (ou Ctrl+C).
set -u
AQUI="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=lib/comum.sh
. "$AQUI/lib/comum.sh" 2>/dev/null || . "$AQUI/mac/lib/comum.sh"
printf '\033]0;Biblioteca Offline - feche esta janela para sair\007'
pausa() { echo; read -r -p "  Aperte Enter para fechar / Press Enter to close... " _; }
achar_raiz "$AQUI" || { pausa; exit 1; }
cd "$RAIZ" || exit 1
achar_python || { pausa; exit 1; }
if [ ! -d "$RAIZ/Programas/KiwixServe/macos" ] && ! command -v kiwix-serve >/dev/null 2>&1; then
  echo "  Aviso: kiwix-serve para Mac não instalado (enciclopédias não vão abrir)."
  echo "  Rode instalar_biblioteca.command (ou: brew install kiwix-tools)."
fi
exec "$PYTHON" -X utf8 "$MACLIB/rodar.py" app "$@"
