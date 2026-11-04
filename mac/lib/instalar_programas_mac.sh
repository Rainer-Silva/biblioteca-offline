#!/bin/bash
# Instala as versões macOS dos programas (o kit traz/baixa só as do Windows):
#   kiwix-serve + kiwix-manage  -> Programas/KiwixServe/macos/   (binários oficiais do Kiwix, estáticos)
#   llama-server (llama.cpp)    -> Programas/LlamaCpp/macos/     (release oficial do ggml-org)
# Se o Homebrew já tiver kiwix-tools / llama.cpp instalados, o app também os acha pelo PATH.
# Sem sudo. Retomável. As versões do Windows continuam intactas ao lado.
set -u
KIWIX_VER="${KIWIX_VER:-3.8.1}"
LLAMA_VER="${LLAMA_VER:-b11889}"   # mesma versão que o kit usa no Windows
# shellcheck source=lib/comum.sh
. "$(dirname "$0")/comum.sh"
: "${RAIZ:?RAIZ não definida}"

ARQ="$(arquitetura)"
case "$ARQ" in
  arm64)  KIWIX_ARQ=macos-arm64;  LLAMA_ARQ=macos-arm64 ;;
  *)      KIWIX_ARQ=macos-x86_64; LLAMA_ARQ=macos-x64 ;;
esac
DL="$RAIZ/6_Instaladores/macos"
mkdir -p "$DL"

instalar_tar() {   # instalar_tar URL ARQUIVO DESTINO BINARIO_ESPERADO
  local url="$1" arq="$DL/$2" dest="$3" bin="$4" tmp
  if [ -x "$dest/$bin" ] && [ -f "$dest/.instalado" ] && grep -qx "$2" "$dest/.instalado"; then
    echo "  ok: $bin já instalado ($2)"; return 0
  fi
  echo "  Baixando $2 ..."
  baixar "$url" "$arq" || { echo "  FALHOU o download de $url"; return 1; }
  tmp="$dest.tmp.$$"
  mkdir -p "$tmp"
  tar -xzf "$arq" -C "$tmp" || { echo "  FALHOU ao descompactar $arq"; return 1; }
  mkdir -p "$dest"
  # achata: copia o conteúdo da pasta onde está o binário (dylibs do llama.cpp ficam ao lado)
  local onde
  onde="$(dirname "$(find "$tmp" -type f -name "$bin" | head -n 1)")"
  [ -n "$onde" ] && [ -f "$onde/$bin" ] || { echo "  $bin não encontrado em $arq"; return 1; }
  cp -R "$onde"/. "$dest"/
  rm -rf "$tmp"   # só a pasta temporária criada acima
  chmod +x "$dest"/* 2>/dev/null || true   # em exFAT não tem efeito (tudo já é executável)
  # arquivos baixados com curl não recebem quarentena, mas se vieram copiados de um navegador, tira:
  xattr -dr com.apple.quarantine "$dest" 2>/dev/null || true
  echo "$2" > "$dest/.instalado"
  echo "  instalado: $dest/$bin"
}

echo "== Programas para macOS ($ARQ) =="
instalar_tar "https://download.kiwix.org/release/kiwix-tools/kiwix-tools_${KIWIX_ARQ}-${KIWIX_VER}.tar.gz" \
  "kiwix-tools_${KIWIX_ARQ}-${KIWIX_VER}.tar.gz" "$RAIZ/Programas/KiwixServe/macos" kiwix-serve || ERRO=1
instalar_tar "https://github.com/ggml-org/llama.cpp/releases/download/${LLAMA_VER}/llama-${LLAMA_VER}-bin-${LLAMA_ARQ}.tar.gz" \
  "llama-${LLAMA_VER}-bin-${LLAMA_ARQ}.tar.gz" "$RAIZ/Programas/LlamaCpp/macos" llama-server || ERRO=1

if [ "${ERRO:-0}" = 1 ] && command -v brew >/dev/null 2>&1; then
  echo "  Alternativa / alternative:  brew install kiwix-tools llama.cpp"
fi
exit "${ERRO:-0}"
