#!/usr/bin/env bash
# Build reprodutível do Espectro para os alvos suportados.
#
# Uso:
#   tool/build_portable.sh web
#   tool/build_portable.sh android
#   tool/build_portable.sh linux
#   tool/build_portable.sh windows
#   tool/build_portable.sh all
#
# "all" compila web + Android + o desktop do sistema atual. Windows só pode ser
# compilado em Windows; Linux só pode ser compilado em Linux.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

TARGET="${1:-web}"

build_web() {
  # O worker offline é próprio (web/espectro_sw.js); o worker gerado pelo
  # Flutter 3.47 se desregistra e não deve ser usado.
  # --no-source-maps evita expor mapas de código-fonte Dart em produção.
  flutter build web --release --no-source-maps
  rm -f "$ROOT/build/web/"*.map
  # Remove comentários sourceMappingURL dos JS para evitar falsos erros 404/JSON.parse no DevTools
  python3 -c '
import glob, re
for p in glob.glob("build/web/*.js") + glob.glob("build/web/canvaskit/**/*.js", recursive=True):
    with open(p, "r", encoding="utf-8", errors="ignore") as f:
        s = f.read()
    ns = re.sub(r"\n?//# sourceMappingURL=[^\n]*", "", s)
    if ns != s:
        with open(p, "w", encoding="utf-8") as f:
            f.write(ns)
'
  python3 "$ROOT/tool/seo/generate_programmatic_seo.py"
  local sw_out="$ROOT/build/web/espectro_sw.js"
  if [[ -f "$sw_out" ]]; then
    local build_stamp
    build_stamp="$(date -u +%Y%m%d%H%M%S)"
    local tmp_sw="${sw_out}.tmp"
    awk -v stamp="$build_stamp" '{gsub("espectro-shell-v2", "espectro-shell-v2-" stamp); print}' "$sw_out" > "$tmp_sw"
    mv "$tmp_sw" "$sw_out"
  fi
}

build_android() {
  flutter build apk --release --dart-define=ESPECTRO_WEB_URL=https://espectro-politico.web.app
}

build_linux() {
  if [[ "$(uname -s)" != "Linux" ]]; then
    echo "Linux só pode ser compilado em Linux." >&2
    return 1
  fi
  flutter build linux --release
}

build_windows() {
  case "$(uname -s)" in
    MINGW*|MSYS*|CYGWIN*) flutter build windows --release ;;
    *)
      echo "Windows só pode ser compilado em Windows." >&2
      return 1
      ;;
  esac
}

case "$TARGET" in
  web) build_web ;;
  android) build_android ;;
  linux) build_linux ;;
  windows) build_windows ;;
  all)
    build_web
    build_android
    case "$(uname -s)" in
      Linux) build_linux ;;
      MINGW*|MSYS*|CYGWIN*) build_windows ;;
    esac
    ;;
  *)
    echo "Alvo desconhecido: $TARGET (use web, android, linux, windows ou all)" >&2
    exit 2
    ;;
esac
