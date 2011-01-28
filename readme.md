# HVA - HTML Video Automator

Author: Loïc Cattani "Arko" <loic.cattani@gmail.com>
Begin:  2011.01.28

# Projet

## Définition du problème

Nous avons des vidéos qui arrivent dans n'importe quels formats et nous voulons les rendre disponible à tous sur internet

## Besoins fonctionnels

Une boîte de dépôt (dropbox) est définie dans laquelle on place les fichiers à traiter. Cette boîte est surveillée et un script est lancé dès qu'un fichier s'y trouve ajouté. Ce script encode les vidéos dans les formats requis et génère un document HTML présentant la vidéo à l'aide de l'élément HTML5 `<video>` et des scripts/styles [videojs](http://videojs.com/).

### Boucle de traitement

  1. Liste les fichiers présents dans la dropbox
  2. Encode les fichiers dans les formats H.264 et webm à l'aide de ffmpeg
  3. Génère un document HTML par vidéo en utilisant la syntaxe videojs
  4. Copie sur le serveur web les fichiers encodés et le document HTML
  5. Archive les sources sur un autre serveur/volume?
  6. Vérifie éventuellement que les fichiers ont bien été transmis.
  7. Nettoie les fichiers restés en local (Fichiers encodés et sources).

Un log des opérations effectuées peut être utile

## Design

Au lancement du script un fichier .lock est placé à coté du script. (Il empêche une seconde instance du script de se lancer au même moment)
Le script attend 1 seconde et revérifie.
Boucle de traitement.
Le script vérifie si de nouveaux fichiers sont présents. Si oui, la boucle de traitement est relancée avec ces nouveaux fichiers. Si non, exit.

# Problèmes à résoudre / Questions

  - Profils vidéo pour l'encodage (Quelle cible visons-nous: taille, débit, qualité, etc... )

# Configuration

Prévoir de pouvoir configurer:

  - Environnement ( Dev || Prod )
  - Profils utiliser pour l'encodage
  - L'adresse du serveur www (et autres params SSH?)
  - L'adresse du serveur d'archivage (et autres params SSH?)

# Installation

## Surveillance de la boîte de dépôt

La surveillance de la boîte de dépôt est prise en charge par launchd et sa méchanique de *watchpaths*.

Un exemple de fichier .plist se trouve juste à coté: `ch.unil.hva.plist`. Ce fichier est configuré pour le développement. Il doit être modifié pour la production à l'aide des informations se trouvant dans la section "production" ci-dessous.

### Développement:

Bash script: `~/work/hva/hva`  
Dropbox: `~/work/hva/dropbox/`  
Launchd job: `~/Library/LaunchAgents/ch.unil.hva.plist`  

**Pour installer:**

    cp ch.unil.hva.plist ~/Library/LaunchAgents/
    launchctl load ~/Library/LaunchAgents/ch.unil.hva.plist

### Production:

Bash script: `/usr/local/bin/hva`  
Dropbox: `/var/hva/dropbox/`
Dropbox: `/var/hva/dropbox/`
Launchd job: `/Library/LaunchDaemons/ch.unil.hva.plist`  

**Pour installer:**

    sudo cp hva /usr/local/bin
    sudo mkdir -p /var/hva/dropbox
    sudo cp ch.unil.hva.plist /Library/LaunchDaemons/
    sudo launchctl load /Library/LaunchDaemons/ch.unil.hva.plist


