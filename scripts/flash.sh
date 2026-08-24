#!/bin/bash
set -euo pipefail

#
# Affichage
#

assert() {
    printf "\n\033[47;30m %-60s \033[0m\n\n" "$1"
}

#
# Répertoires
#

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

IMAGE="$ROOT/output/images/kbrd.img"
USBBOOT="$ROOT/usbboot"

#
# Vérifications
#

if [ ! -f "$IMAGE" ]; then
    echo "Image introuvable : $IMAGE"
    exit 1
fi

#
# Démarrage du Raspberry en mode stockage USB
#

clear

assert "Démarrage du Raspberry en périphérique de stockage"

cd "$USBBOOT"
sudo ./rpiboot -d mass-storage-gadget64

#
# Détection du périphérique
#

assert "En attente du Raspberry"

while true; do
    DEVICE=$(lsblk -dn -o NAME,MODEL,TRAN | \
        awk '$NF == "usb" && /Raspberry Pi multi-function USB device/ {print "/dev/"$1; exit}')

    [ -n "$DEVICE" ] && break

    sleep 1
done

assert "Périphérique détecté : $DEVICE"

#
# Écriture de l'image
#

assert "Écriture de l'image KBRD"

pv -f "$IMAGE" | \
    sudo dd \
        of="$DEVICE" \
        bs=4M \
        iflag=fullblock \
        oflag=direct

#
# Flush
#

assert "Synchronisation du périphérique"

sudo blockdev --flushbufs "$DEVICE"

#
# Éjection
#

assert "Éjection du périphérique"

sudo eject "$DEVICE"

#
# Terminé
#

assert "Transfert terminé"