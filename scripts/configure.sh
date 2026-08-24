#!/bin/bash

set -e

#
# Fonctions
#

assert() {
    printf "\n\033[47;30m %-60s \033[0m\n\n" "$1"
}

#
# Chemins
#

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

SSH_DIR="$HOME/.ssh"
SSH_KEY="$SSH_DIR/kbrd"

AUTHORIZED_KEYS="$ROOT_DIR/kbrd-os/board/kbrd/rootfs-overlay/home/kbrd/.ssh/authorized_keys"

#
# Configuration SSH
#

assert "Configuration SSH"

mkdir -p "$SSH_DIR"
chmod 700 "$SSH_DIR"

if [ ! -f "$SSH_KEY" ]; then
    echo "Génération de la clé SSH : $SSH_KEY"

    ssh-keygen \
        -t ed25519 \
        -f "$SSH_KEY" \
        -N "" \
        -C "kbrd"
else
    echo "Clé SSH existante : $SSH_KEY"
fi

chmod 600 "$SSH_KEY"
chmod 644 "$SSH_KEY.pub"

#
# Configuration Buildroot
#

assert "Configuration Buildroot"

mkdir -p "$(dirname "$AUTHORIZED_KEYS")"

cp "$SSH_KEY.pub" "$AUTHORIZED_KEYS"

echo "Clé publique installée :"
echo "$AUTHORIZED_KEYS"

#
# Fin
#

assert "Configuration terminée"