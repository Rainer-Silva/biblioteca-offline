#!/bin/bash
# Funções comuns dos scripts macOS da Biblioteca Offline. / Shared helpers for the macOS scripts.
# Uso: source "$(dirname "$0")/lib/comum.sh"

# RAIZ = pasta da biblioteca (onde estão App/, _Baixador/, Programas/).
# Os .command podem ficar na raiz do SSD ou dentro da pasta mac/.
achar_raiz() {
  local d="$1"
  if [ -d "$d/App" ] && [ -d "$d/_Baixador" ]; then RAIZ="$d"
  elif [ -d "$d/../App" ] && [ -d "$d/../_Baixador" ]; then RAIZ="$(cd "$d/.." && pwd)"
  else
    echo
    echo "  Não achei as pastas App e _Baixador. Descompacte o kit INTEIRO no SSD e"
    echo "  coloque a pasta 'mac' dentro dele (ao lado de App)."
    echo "  Could not find App/ and _Baixador/. Unzip the whole kit to the SSD and put the"
    echo "  'mac' folder inside it (next to App)."
    return 1
  fi
  if [ -d "$RAIZ/mac/lib" ]; then MACLIB="$RAIZ/mac/lib"; else MACLIB="$d/lib"; fi
  export RAIZ MACLIB BIBLIOTECA_RAIZ="$RAIZ"
}

# Arquitetura: arm64 (Apple Silicon) ou x86_64 (Intel). Sob Rosetta, uname -m mente: usa sysctl.
arquitetura() {
  if [ "$(sysctl -n hw.optional.arm64 2>/dev/null)" = "1" ]; then echo arm64; else echo x86_64; fi
}

# Python 3.9+ com sqlite FTS5 (a busca usa FTS5). Prefere Homebrew, depois python.org, depois o do sistema.
achar_python() {
  local c
  for c in /opt/homebrew/bin/python3 /usr/local/bin/python3 \
           /Library/Frameworks/Python.framework/Versions/Current/bin/python3 python3; do
    command -v "$c" >/dev/null 2>&1 || continue
    # /usr/bin/python3 sem as Command Line Tools abre um diálogo de instalação: testa sem travar
    if "$c" -c 'import sys,sqlite3; assert sys.version_info>=(3,9); c=sqlite3.connect(":memory:"); c.execute("create virtual table t using fts5(x)")' >/dev/null 2>&1; then
      PYTHON="$(command -v "$c")"; export PYTHON; return 0
    fi
  done
  echo
  echo "  Preciso do Python 3.9 ou mais novo (com SQLite FTS5)."
  echo "  Need Python 3.9+ (with SQLite FTS5). Install ONE of:"
  echo "    brew install python            (https://brew.sh)"
  echo "    https://www.python.org/downloads/macos/   (instalador oficial / official installer)"
  return 1
}

# Espaço livre em bytes na pasta $1 (df -k funciona em exFAT/APFS/HFS+).
livre_bytes() { df -Pk "$1" | awk 'NR==2 {print $4 * 1024}'; }
livre_gb() { df -Pk "$1" | awk 'NR==2 {printf "%.1f", $4 / 1048576}'; }

# Formato do volume (exfat, apfs, hfs, msdos...). Avisa sobre FAT32 (limite de 4 GB por arquivo).
checar_volume() {
  local fs
  fs="$(stat -f %T "$1" 2>/dev/null || true)"
  [ -z "$fs" ] && fs="$(df -T "$1" 2>/dev/null | awk 'NR==2 {print $2}')"
  case "$fs" in
    msdos|vfat|fat32)
      echo "  ATENÇÃO: este volume é FAT32 (máx. 4 GB por arquivo). Formate em exFAT."
      echo "  WARNING: FAT32 volume (4 GB file limit). Reformat as exFAT."; return 1 ;;
    ntfs)
      echo "  ATENÇÃO: NTFS é somente leitura no macOS. Use exFAT para usar no Mac e no Windows."
      echo "  WARNING: NTFS is read-only on macOS. Use exFAT for Mac + Windows."; return 1 ;;
  esac
  return 0
}

# Download retomável: baixar URL DESTINO  (grava em DESTINO.part e renomeia no fim)
baixar() {
  local url="$1" dest="$2" t
  mkdir -p "$(dirname "$dest")"
  [ -f "$dest" ] && [ -f "$dest.ok" ] && return 0
  for t in 1 2 3 4 5; do
    if curl -fL -C - --retry 5 --retry-delay 15 --connect-timeout 30 \
         --speed-limit 20000 --speed-time 120 -o "$dest.part" "$url"; then
      mv -f "$dest.part" "$dest" && echo "$url" > "$dest.ok" && return 0
    fi
    sleep $((10 * t))
  done
  return 1
}
