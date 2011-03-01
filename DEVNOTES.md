# HTML Video Automator (HVA)

Author: Loïc Cattani "Arko" <loic.cattani@gmail.com>  
Begin:  2011.01.28

## Définition du problème

Nous avons des vidéos qui arrivent dans n'importe quels formats et nous voulons les rendre disponible à tous sur internet

## Besoins fonctionnels

Une boîte de dépôt est définie dans laquelle on place les fichiers à traiter. Cette boîte est surveillée et un script est lancé dès qu'un fichier s'y trouve ajouté. Ce script encode les vidéos dans les formats requis et génère un document HTML présentant la vidéo. Il copie ensuite l'ensemble des fichiers sur un serveur web.

### Boucle de traitement

  1. Liste et vérifie les fichiers soumis et présents dans la dropbox
  2. Encode les fichiers dans les formats mp4 et webm et crée un poster à l'aide de ffmpeg
  3. Génère un document HTML par vidéo en utilisant la syntaxe videojs
  4. Copie sur le serveur web les fichiers encodés et le document HTML
  5. Archive les sources sur un autre serveur/volume, sinon sur le serveur web.
  6. Nettoie les fichiers restés en local.

L'application loggue les opérations effectuées

## Design

La vidéo est présentée à l'aide de l'élément HTML5 `<video>` et de [VideoJS](http://videojs.com/).

### Workflow type

1. Les fichiers vidéo sont téléchargés dans la dropbox.
2. Une page web permet de séléctionner les fichiers à traiter et lancer un nouveau 'job'.
3. La progression du travail est affichée (auto refresh) et des liens vers les vidéos sont proposés une fois le 'job' terminé
4. On visite, utilise tel quel ou copie le code généré pour chaque vidéo.

### Détails

L'étape numéro 2 est contituée d'une page web générée dynamiquement et listant les fichiers présents dans la dropbox. Des cases à cocher permettent de séléctionner les fichiers à soumettre par POST. Ceci lancant un nouveau job HVA.

Pour des raisons de sécurité, les valeurs soumises ne devraient pas contenir les noms de fichiers mais plutôt un digest de ces derniers.

Un script ruby CGI s'occupe de tout ceci.

### Ecrasement de fichiers déjà présents

Si un fichier portant le même nom qu'un fichier déjà traité est soumis à HVA, il sera traité sans distinction et le fichier précedemment traité sera écrasé. Cela est souhaité afin de permettre le réencodage d'un fichier qui aurait été modifié depuis son premier traitement.

## Problèmes à résoudre / Questions

  - Profils vidéo pour l'encodage (Quelle cible visons-nous: taille, débit, qualité, etc... ): Vérifier!

## Configuration

Prévoir de pouvoir configurer:

  - Profils utilisés pour l'encodage

# TODO

  - Afficher warning en cas de nom déjà existant dans publish ou archive. (?)
  - Ajouter métadonnées (Ce qu'on a) dans la template HTML pour info
  - Changelog dès initial release
  - p2: Afficher partie de log propre au job dans job report
  - Déplacer les fichiers en traitement pour ne plus les avoir dans la dropbox
  - Vérifier propriétés CSS3 pour autres pour autres navigateurs (vendor prefixes)
  - Utiliser les classes modernizr pour styler en fonction des capacités des navigateurs
  - Options parametrables (Bien réfléchir à comment l'implémenter pour que cela reste simple, limpide et inobtrusif)
    - Taille de la vidéo (p.ex 565 max width pr Jahia)
    - Position temporelle du poster
  - Publier et Archiver les fichiers dans dossier numéroté par job
  
# Failles de sécurité

  1. Un nom de fichier préparé pour exploiter cette faille peut executer du code en ligne de commande sous l'utilisateur actuel
     In: worker.rb, lines 15, 19, 38, 100
     In: video.rb, line 38
     => Partout ou le chemin du fichier (video.path) est utilisé dans une commande système
     Priorité: moyenne (La dropbox n'étant pas en libre accès)
  