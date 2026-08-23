#!/bin/sh
set -eu

ROOT="$PWD"
OUT="$ROOT/output"
BR="$ROOT/buildroot"
EXT="$ROOT/kbrd-os"

WEB="$ROOT/kbrd-web"
API="$ROOT/kbrd-api"
DEV="$ROOT/kbrd-dev"

echo "Suppression complète de $OUT"
rm -rf "$OUT"

# On build kbrd-web
cd "$WEB"
npm run build

# On bumd la version dans le mk
WEB_VER=$(git rev-parse --short=12 HEAD)
MK="$EXT/package/kbrd-web/kbrd-web.mk"

# remplace la ligne KBRD_WEB_VERSION = ...
sed -i "s/^KBRD_WEB_VERSION = .*/KBRD_WEB_VERSION = ${WEB_VER}/" "$MK"

echo "kbrd-web: $WEB_VER"

# Reconstruction de buildroot
cd "$ROOT"
rm -f "$OUT/images/"*.img || true

cp $EXT/board/kbrd/cmdline-prod.txt $EXT/board/kbrd/cmdline.txt

make -C "$BR" BR2_EXTERNAL="$EXT" O="$OUT" kbrd_defconfig

# Force la reconstruction des packages locaux
make -C "$BR" BR2_EXTERNAL="$EXT" O="$OUT" kbrd-web-rebuild
make -C "$BR" BR2_EXTERNAL="$EXT" O="$OUT" kbrd-api-rebuild
make -C "$BR" BR2_EXTERNAL="$EXT" O="$OUT" kbrd-dev-rebuild

# Génération de l'image
make -C "$BR" BR2_EXTERNAL="$EXT" O="$OUT"