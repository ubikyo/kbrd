<img src="resources/KBRD.svg" width="400">


# Description

KBRD est un POC de fabrication d'un clavier utilisant l'effet Maglev. Il utilise une carte Raspberry CM4 (ou tout autre raspberry avec stockage eMMC), un écran DSI et une détection des touches par effet Hall. Le projet intègre une interface web pour la configuration du clavier via le réseau Wifi.

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

On clône le dépot et ses sous-modules :

    git clone --recurse-submodules https://github.com/ubikyo/kbrd.git

## Configuration

Utiliser la commande suivante pour générer une clé SSH pour l'utilisateur kbrd et rattacher les sous-modules à leur branche main :

    make configure

## Compilation

Compiler l'ensemble des modules avec l'un des scripts suivants :

|Script|Quiet|Log level|Bootchart|
|-|-|-|-|
|make build MODE=debug|7|Non|Oui|
|make build MODE=dev|4|Non|Oui|
|make build MODE=prod|3|Oui|Non|

> **NOTE 1 :**  La compilation dure environ 40 minutes à 1h. Elle construit l'image de **KBRD-OS** ainsi que les packages **KBRS-DEV**, **KBRD-API** et **KBRD-WEB**.

> **NOTE 2 :**  Une fois la compilation terminée, l'image pour le raspberry est disponible dans /**output/images/kbrd.img**.

> **NOTE 3 :**  Il est possible d'ajouter **CLEAN=true** pour effacer la compilation précédente.

## Transfert de l'image

Vérifier que l'image est disponible dans le dossier **/output/images/kbrd.img**. Connecter via le port USBC, le raspberry, sur l'ordinateur avec l'interrupteur **BOOT** activé. 

Installer pv :

    sudo apt install pv :

Lancer le transfert :

    make flash

Une fois terminé on désactive le mode **BOOT** boot via l'interrupteur et on redémarre le raspberry.

## Connexion SSH vers le raspberry

Pour actualiser les composants du raspberry, il est nécessaire de définir au préalable une connexion SSH vers l'adresse IP associée au clavier. 

Modifier le fichier de configuration :

    sudo nano .ssh/config

Ajouter la configuration suivante :

    Host kbrd
        HostName {ip_ou_fqdn_du_raspberry}
        User kbrd
        StrictHostKeyChecking no
        IdentityFile ~/.ssh/kbrd
        IdentitiesOnly yes
        StrictHostKeyChecking no
        UserKnownHostsFile /dev/null

## Actualisation des composants

KBRD-DEV, KBRD-API et KBRD-WEB doivent être redéployés sur le périphérique après toute mise à jour. Pour éviter de refaire systématiquement l'image et de transférer celle-ci sur le raspberry, il est possible d'utiliser l'une des commandes suivantes :

|Commande|Description|
|-|-|
|make deploy|Déploie l'ensemble des composant|
|make deploy PACKAGE=dev|Déploie KBRD-DEV|
|make deploy PACKAGE=api|Déploie KBRD-API|
|make deploy PACKAGE=web|Déploie KBRD-WEB|

> **NOTE :**  Le déploiement redémarre les services associés à KBRD-DEV et KBRD-API.

