# HVA - HTML Video Automator

Author: Loïc Cattani "Arko" <loic.cattani@gmail.com>
Begin:  2011.01.28

# Projet

## Définition du problème

Nous avons des vidéos qui arrivent dans n'importe quels formats et nous voulons les rendre disponible à tous sur internet

## Besoins fonctionnels

Une boîte de dépôt est définie dans laquelle on place les fichiers à traiter. Cette boîte est surveillée et un script est lancé dès qu'un fichier s'y trouve ajouté. Ce script encode les vidéos dans les formats requis et génère un document HTML présentant la vidéo à l'aide de l'élément HTML5 `<video>` et des scripts/styles [videojs](http://videojs.com/). Il copie ensuite l'ensemble des fichiers sur un serveur web.

### Boucle de traitement

  1. Liste les fichiers présents dans la launchpad
  2. Encode les fichiers dans les formats H.264 et webm à l'aide de ffmpeg
  3. Génère un document HTML par vidéo en utilisant la syntaxe videojs
  4. Copie sur le serveur web les fichiers encodés et le document HTML
  5. Archive les sources sur un autre serveur/volume?
  6. Vérifie éventuellement que les fichiers ont bien été transmis.
  7. Nettoie les fichiers restés en local (Fichiers encodés et sources).

Un log des opérations effectuées peut être utile

## Design

Le fichiers copiés depuis les clients distants arrivent dans `arrival`. Une fois la copie terminée, le client déplace les fichiers dans `launchpad`. Ils seront alors automatiquement encodés dans `payload` et seront ensuite copié sur le serveur web.

Ceci permet d'assurer que les fichiers présents dans la boîte de dépôt soient tous complets et prêt au traitement. Car sinon il n'y a pas de moyen fiable d'être sûr que le fichier ait été entièrement copié. Une validation de la part du client est le plus simple et le plus sûr.

La surveillance de la boîte de dépôt `launchpad` est prise en charge par launchd et sa méchanique de *watchpaths*. Un exemple de fichier .plist préparé pour le dev se trouve juste à coté: `ch.unil.hva.plist`.

Une fois la copie vers le serveur web effectuée les fichiers n'ont plus besoin de rester en local. Ils sont alors selectivement supprimés. (Fichiers sources dans `launchpad`, fichiers encodés et documents HTML dans `payload`. Le contenu de `arrival` n'est pas touché.)

# Problèmes à résoudre / Questions

  - Profils vidéo pour l'encodage (Quelle cible visons-nous: taille, débit, qualité, etc... )
  - Assurer que les fichiers soient d'abord copiés dans `arrival` avant d'être déplacé dans `launchpad`. Ceci de manière sécurisée. (sftp: *ForceCommand internal-sftp*?)

# Configuration

Prévoir de pouvoir configurer:

  - Profils utiliser pour l'encodage
  - L'adresse du serveur www (et autres params SSH?)
  - L'adresse du serveur d'archivage (et autres params SSH?)

# TODO

  - Much
  