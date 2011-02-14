# HVA - HTML Video Automator

Author: Loïc Cattani "Arko" <loic.cattani@gmail.com>
Begin:  2011.01.28

# Projet

## Définition du problème

Nous avons des vidéos qui arrivent dans n'importe quels formats et nous voulons les rendre disponible à tous sur internet

## Besoins fonctionnels

Une boîte de dépôt est définie dans laquelle on place les fichiers à traiter. Cette boîte est surveillée et un script est lancé dès qu'un fichier s'y trouve ajouté. Ce script encode les vidéos dans les formats requis et génère un document HTML présentant la vidéo à l'aide de l'élément HTML5 `<video>` et des scripts/styles [videojs](http://videojs.com/). Il copie ensuite l'ensemble des fichiers sur un serveur web.

### Boucle de traitement

  1. Liste et vérifie les fichiers soumis et présents dans la dropbox
  2. Encode les fichiers dans les formats mp4 et webm et crée un poster à l'aide de ffmpeg
  3. Génère un document HTML par vidéo en utilisant la syntaxe videojs
  4. Copie sur le serveur web les fichiers encodés et le document HTML
  5. Archive les sources sur un autre serveur/volume, sinon sur le serveur web.
  6. Nettoie les fichiers restés en local.

L'application loggue les opérations effectuées

## Design

Dans un premier temps, les fichiers vidéo sont téléchargés dans la dropbox. Une deuxième étape permet de séléctionner les fichiers à traiter et lancer le script.

Cette seconde étape est contituée d'une page web générée dynamiquement et listant les fichiers présents dans la dropbox. Des cases à cocher permettent de séléctionner les fichiers à soumettre par POST. Ceci lancant un nouveau job HVA.

Pour des raisons de sécurité, les valeurs soumises ne devraient pas contenir les noms de fichiers mais plutôt un digest de ces derniers.

Un script ruby CGI s'occupe de tout ceci.

### Ecrasement de fichiers déjà présents

Si un fichier portant le même nom qu'un fichier déjà traité est soumis à HVA, il sera traité sans distinction et le fichier précedemment traité sera écrasé. Cela est souhaité afin de permettre le réencodage d'un fichier qui aurait été modifié depuis son premier traitement.

# Problèmes à résoudre / Questions

  - Profils vidéo pour l'encodage (Quelle cible visons-nous: taille, débit, qualité, etc... ): Vérifier!
  - Archiver les sources ailleurs que sur le serveur web? Ou?

# Configuration

Prévoir de pouvoir configurer:

  - Profils utilisés pour l'encodage

# TODO

  - "Slugifier" les noms de fichiers en entrée (Pour URLs)
  - Page listant les fichiers présents dans dropbox et permettant de lancer la conversion manuellement
  - Afficher warning en cas de nom déjà existant dans publish ou archive.
  - Prendre poster à 50% de la vidéo
  - Ajouter métadonnées (Ce qu'on a) dans la template HTML pour info
  - Permettre la génération d'un poster en png
  - Changelog dès initial release
  - Etudier et corriger ce problème de texte avec double transparence
  - Ajouter validation et infos video dans la vue dropbox
