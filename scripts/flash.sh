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

MODE="${1:-update}"
IMAGE="$ROOT/output/images/kbrd.img"
BOOT_IMAGE="$ROOT/output/images/boot.vfat"
ROOTFS_IMAGE="$ROOT/output/images/rootfs.ext4"
USBBOOT="$ROOT/usbboot"

#
# Vérifications
#

case "$MODE" in
    update)
        for FILE in "$BOOT_IMAGE" "$ROOTFS_IMAGE"; do
            if [ ! -f "$FILE" ]; then
                echo "Image introuvable : $FILE"
                exit 1
            fi
        done
        ;;
    full)
        if [ ! -f "$IMAGE" ]; then
            echo "Image introuvable : $IMAGE"
            exit 1
        fi
        ;;
    *)
        echo "Usage : $0 {update|full}"
        exit 1
        ;;
esac

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
# Démontage des partitions éventuellement montées par l'hôte
#

while read -r PARTITION; do
    if [ "$PARTITION" != "$DEVICE" ]; then
        sudo umount "$PARTITION" 2>/dev/null || true
    fi
done < <(lsblk -lnpo NAME "$DEVICE")

#
# Écriture
#

if [ "$MODE" = "full" ]; then
    assert "Écriture complète de l'image KBRD (partition data incluse)"

    pv -f "$IMAGE" | \
        sudo dd \
            of="$DEVICE" \
            bs=4M \
            iflag=fullblock \
            oflag=direct
else
    assert "Recherche des partitions boot et rootfs"

    BOOT_DEVICE=""
    ROOTFS_DEVICE=""

    for _ in $(seq 1 30); do
        BOOT_DEVICE=$(lsblk -lnpo NAME,PARTN "$DEVICE" | awk '$2 == 1 {print $1; exit}')
        ROOTFS_DEVICE=$(lsblk -lnpo NAME,PARTN "$DEVICE" | awk '$2 == 2 {print $1; exit}')

        if [ -n "$BOOT_DEVICE" ] && [ -n "$ROOTFS_DEVICE" ]; then
            break
        fi

        sleep 1
    done

    if [ -z "$BOOT_DEVICE" ] || [ -z "$ROOTFS_DEVICE" ]; then
        echo "Partitions boot/rootfs introuvables sur $DEVICE."
        echo "Utiliser 'make flash-full' pour initialiser complètement le stockage."
        exit 1
    fi

    BOOT_IMAGE_SIZE=$(stat -c %s "$BOOT_IMAGE")
    ROOTFS_IMAGE_SIZE=$(stat -c %s "$ROOTFS_IMAGE")
    BOOT_DEVICE_SIZE=$(sudo blockdev --getsize64 "$BOOT_DEVICE")
    ROOTFS_DEVICE_SIZE=$(sudo blockdev --getsize64 "$ROOTFS_DEVICE")

    if [ "$BOOT_IMAGE_SIZE" -gt "$BOOT_DEVICE_SIZE" ]; then
        echo "L'image boot est trop grande pour $BOOT_DEVICE."
        exit 1
    fi

    if [ "$ROOTFS_IMAGE_SIZE" -gt "$ROOTFS_DEVICE_SIZE" ]; then
        echo "L'image rootfs est trop grande pour $ROOTFS_DEVICE."
        exit 1
    fi

    assert "Écriture de boot sur $BOOT_DEVICE"

    pv -f "$BOOT_IMAGE" | \
        sudo dd \
            of="$BOOT_DEVICE" \
            bs=4M \
            iflag=fullblock \
            oflag=direct

    assert "Écriture de rootfs sur $ROOTFS_DEVICE"

    pv -f "$ROOTFS_IMAGE" | \
        sudo dd \
            of="$ROOTFS_DEVICE" \
            bs=4M \
            iflag=fullblock \
            oflag=direct

    assert "Partition data conservée"
fi

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
