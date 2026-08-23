<img src="resources/KBRD.svg" width="300">


# Description

KBRD est un POC de fabrication d'un clavier utilisant l'effet Maglev, une carte Raspberry CM4 (ou tout autre raspberry avec stockage eMMC), un écran DSI et une détection des touches par effet Hall. Le projet intègre une interface web pour la configuration du clavier via le réseau Wifi.

# Modules

|Module|Description|
|-|-|
|[KBRD-OS](https://github.com/ubikyo/kbrd-os)|Système d'exploitation pour le clavier|
|[KBRD-DEV](https://github.com/ubikyo/kbrd-dev)|Logiciel embarqué par le PI pour afficher le clavier|
|[KBRD-API](https://github.com/ubikyo/kbrd-api)|API REST pour échange entre les modules|
|[KBRD-WEB](https://github.com/ubikyo/kbrd-web)|Interface web pour la configuration du clavier|


# Développement
Le développement est associé aux éléments suivants :

|Element|Description|
|-|-|
|[Raspberry Compute Model 4](https://www.raspberrypi.com/products/compute-module-4/)|Raspberry au format compact|
|[Waveshare CM4-IO-BASE-A](https://www.waveshare.com/wiki/CM4-IO-BASE-A)|Carte de développement Waveshare pour Raspberry CM4|
|[Waveshare 10.1-DSI-TOUCH-A](https://www.waveshare.com/wiki/10.1-DSI-TOUCH-A)|Ecran au format DSI|
|[SH-U07A](https://www.deshide.com/product-details_SH-U07A.html)|Un adaptateur USB to TTL connecté entre les ports GND/RX/TX de l'adaptateur et du CM4-IO-BASE-A pour obtenir la console **ttyAMA0**.|

## Déploiement des dépôts

Sur une VM ou localment, on stocke les clés SSH en mémoire dans le shell actuel :

    eval "$(ssh-agent -s)"

On ajoute la clé privée dans l'agent (à adapter selon le nom de la clé SSH de l'utilisateur) :

    ssh-add ~/.ssh/id_ed25519

On clône le dépot :

    git clone git@github.com:ubikyo/kbrd.git

On initialise les dépôts :

    git submodule update --init --recursive


## Compilation

Compiler l'ensemble des modules avec l'un des scripts suivants :

|Script|Quiet|Log level|Bootchart|
|-|-|-|-|
|build-debug.sh|7|Non|Oui|
|build-dev.sh|4|Non|Oui|
|build-prod.sh|3|Oui|Non|

> **NOTE 1 :**  La compilation dure environ 40 minutes à 1h. Elle construit l'image de **KBRD-OS** ainsi que les packages **KBRS-DEV**, **KBRD-API** et **KBRD-WEB**.

> **NOTE 2 :**  Une fois la compilation terminée, l'image pour le raspberry est disponible dans /**output/images/kbrd.img**.

Une fois la compilation terminée, réaliser le [transfert de l'image vers le raspberry](https://github.com/ubikyo/kbrd-os/blob/main/README.md).