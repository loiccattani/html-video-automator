# HVA - HTML Video Automator

Author: Loïc Cattani "Arko" <loic.cattani@gmail.com>
Begin:  2011.01.28

## Définition du problème:

Nous avons des vidéos qui arrivent dans n'importe quels formats et nous voulons les rendre disponible à tous sur internet

## Besoins fonctionnels:

*Que doit faire le programme pour résoudre ce problème:*

Le programme doit offrir une boîte de dépôt dans laquelle on place les fichiers à traiter. Cette boîte est surveillée et le script est lancé dès qu'un nouveau fichier s'y trouve.

### Opération du script:

  1. Encode les fichiers dans les formats H.264 et webm à l'aide de ffmpeg
  2. Copie les fichiers sur le serveur www.
  3. Génère un document HTML5 par vidéo en utilisant la syntaxe videojs
  4. Copie ce document sur le serveur www.
  5. Vérifie éventuellement que les fichiers ont bien été transmis.
  6. Archive les sources et nettoie les fichiers temporaires (Fichiers encodés en local, etc).

## Design:

Au lancement du script un fichier .lock est placé qqpart. Il empêche une seconde instance du script de se lancer au même moment (Avec un délai de x secondes?). A la fin, le script vérifie si de nouveaux fichiers sont présents et relance la boucle de traitement avec ces nouveaux fichiers. etc…
