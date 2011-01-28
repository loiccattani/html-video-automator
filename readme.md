# HVA - HTML Video Automator

Author: Loïc Cattani "Arko" <loic.cattani@gmail.com>
Begin:  2011.01.28

## Définition du problème

Nous avons des vidéos qui arrivent dans n'importe quels formats et nous voulons les rendre disponible à tous sur internet

## Besoins fonctionnels

*Que doit faire le programme pour résoudre ce problème:*

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
