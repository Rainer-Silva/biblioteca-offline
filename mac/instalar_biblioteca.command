#!/bin/bash
# BIBLIOTECA OFFLINE — instalação no macOS (equivalente ao INSTALAR_BIBLIOTECA.bat)
# Dois cliques no Finder. Retomável: se parar, rode de novo e ele continua de onde parou.
# Opções: --verificar (só mostra o que falta)  --sem-mapa  --sem-programas-mac
set -u
AQUI="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=lib/comum.sh
. "$AQUI/lib/comum.sh" 2>/dev/null || . "$AQUI/mac/lib/comum.sh"
printf '\033]0;Biblioteca Offline - instalacao\007'

pausa() { echo; read -r -p "  Aperte Enter para fechar / Press Enter to close... " _; }
achar_raiz "$AQUI" || { pausa; exit 1; }
cd "$RAIZ" || exit 1
echo "========================================================================"
echo "  BIBLIOTECA OFFLINE — instalação (macOS $(sw_vers -productVersion 2>/dev/null), $(arquitetura))"
echo "========================================================================"
echo "  Pasta: $RAIZ"
echo "  Livre: $(livre_gb "$RAIZ") GB   (biblioteca completa ≈ 830 GB: use SSD de 1 TB, ideal 2 TB)"
checar_volume "$RAIZ" || { pausa; exit 1; }
if [ "$(livre_bytes "$RAIZ")" -lt $((20 * 1024 * 1024 * 1024)) ]; then
  echo "  Menos de 20 GB livres: não dá para instalar nem o essencial. / Less than 20 GB free."
  pausa; exit 1
fi
achar_python || { pausa; exit 1; }
echo "  Python: $PYTHON ($("$PYTHON" -V 2>&1))"
command -v curl >/dev/null || { echo "  curl não encontrado"; pausa; exit 1; }

ARGS=()
SEM_PROG=0
for a in "$@"; do
  if [ "$a" = "--sem-programas-mac" ]; then SEM_PROG=1; else ARGS+=("$a"); fi
done

# não deixa o Mac dormir enquanto baixa (sem sudo)
caffeinate -i -w $$ >/dev/null 2>&1 &

case " ${ARGS[*]-} " in *" --verificar "*) SEM_PROG=1 ;; esac
if [ "$SEM_PROG" = 0 ]; then
  bash "$MACLIB/instalar_programas_mac.sh" || echo "  (programas Mac: rode de novo depois / retry later)"
fi

# o instalador original (Python puro) com a camada macOS: curl.exe -> curl etc.
"$PYTHON" -X utf8 "$MACLIB/rodar.py" "_Baixador/instalador/instalar.py" ${ARGS[@]+"${ARGS[@]}"}
echo
echo "  No Mac, para abrir: dois cliques em abrir_biblioteca.command"
pausa
