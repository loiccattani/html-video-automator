# HTML Video Automator (HVA)

Author: Loïc Cattani "Arko" <loic.cattani@gmail.com>  
Begin:  2011.01.28

## Définition du problème

Nous avons des vidéos qui arrivent dans divers formats et nous voulons les rendre disponible à tous via internet

## Besoins fonctionnels

On place les fichiers à traiter dans une boîte de dépôt. Un script encode les vidéos dans les formats requis et génère un document HTML présentant la vidéo. Il copie ensuite l'ensemble des fichiers sur un serveur web.

### Boucle de traitement

  1. Liste et vérifie les fichiers soumis et présents dans la dropbox
  2. Encode les fichiers dans les formats mp4 et webm et crée un poster à l'aide de ffmpeg
  3. Génère un document HTML par vidéo en utilisant la syntaxe videojs
  4. Copie sur le serveur web les fichiers encodés et le document HTML
  5. Archive les sources sur un autre serveur/volume, sinon sur le serveur web.
  6. Nettoie les fichiers restés en local.

L'application loggue les opérations effectuées

## Design

Pour une compatibilité optimale, la vidéo est présentée à l'aide de l'élément HTML5 `<video>` et de [VideoJS](http://videojs.com/).

### Workflow type

1. Les fichiers vidéo sont téléchargés dans la dropbox.
2. Une page web permet de séléctionner les fichiers à traiter et lancer un nouveau 'job'.
3. La progression du travail est affichée (auto refresh) et des liens vers les vidéos sont proposés une fois le 'job' terminé
4. On visite, utilise tel quel ou copie le code généré pour chaque vidéo.

### Détails

L'étape numéro 2 est constituée d'une page web générée dynamiquement et listant les fichiers présents dans la dropbox. Des cases à cocher permettent de séléctionner les fichiers à soumettre par POST. Ceci lancant un nouveau job HVA.

Pour des raisons de sécurité, les valeurs soumises ne devraient pas contenir les noms de fichiers mais plutôt un digest de ces derniers.

Un script ruby CGI s'occupe de tout ceci.

# TODO

  - Changelog dès initial release
  
# Failles de sécurité

  1. Un nom de fichier préparé pour exploiter cette faille peut executer du code en ligne de commande sous l'utilisateur actuel
     In: video.rb => Partout ou le chemin du fichier (video.path) est utilisé dans une commande système
     Priorité: moyenne (La dropbox n'étant pas en libre accès)
  