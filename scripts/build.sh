#!/bin/sh
set -eu

#
# Affichage
#

assert() {
    printf "\n\033[47;30m %-60s \033[0m\n\n" "$1"
}

#
# Paramètres
#

MODE="${1:-}"
CLEAN="${2:-}"

case "$MODE" in
    debug|dev|prod)
        ;;
    *)
        echo "Usage: $0 {debug|dev|prod} [clean]"
        exit 1
        ;;
esac

#
# Répertoires
#

ROOT="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"

OUT="$ROOT/output"
BR="$ROOT/buildroot"
EXT="$ROOT/kbrd-os"
WEB="$ROOT/kbrd-web"

#
# Nettoyage
#

if [ "$MODE" = "prod" ] || [ "$CLEAN" = "clean" ]; then
    assert "Suppression complète de $OUT"
    rm -rf "$OUT"
fi

#
# KBRD-WEB
#

assert "KBRD-WEB : installation des dépendances"

cd "$WEB"
npm install

assert "KBRD-WEB : compilation"

npm run build

#
# Configuration Buildroot
#

assert "KBRD-OS : configuration $MODE"

rm -f "$OUT/images/"*.img 2>/dev/null || true

cp \
    "$EXT/board/kbrd/cmdline-${MODE}.txt" \
    "$EXT/board/kbrd/cmdline.txt"

make -C "$BR" \
    BR2_EXTERNAL="$EXT" \
    O="$OUT" \
    kbrd_defconfig

#
# Reconstruction des packages locaux
#

assert "KBRD-WEB : reconstruction"

make -C "$BR" \
    BR2_EXTERNAL="$EXT" \
    O="$OUT" \
    kbrd-web-rebuild

assert "KBRD-API : reconstruction"

make -C "$BR" \
    BR2_EXTERNAL="$EXT" \
    O="$OUT" \
    kbrd-api-rebuild

assert "KBRD-DEV : reconstruction"

make -C "$BR" \
    BR2_EXTERNAL="$EXT" \
    O="$OUT" \
    kbrd-dev-rebuild

#
# Génération de l'image
#

assert "KBRD-OS : génération de l'image"

make -C "$BR" \
    BR2_EXTERNAL="$EXT" \
    O="$OUT"

#
# Terminé
#

assert "KBRD-OS : build $MODE terminé"
