# HVA - HTML Video Automator

Author: Loïc Cattani "Arko" <loic.cattani@gmail.com>
Begin:  2011.01.28

# Projet

## Définition du problème

Nous avons des vidéos qui arrivent dans n'importe quels formats et nous voulons les rendre disponible à tous sur internet

## Besoins fonctionnels

Une boîte de dépôt est définie dans laquelle on place les fichiers à traiter. Cette boîte est surveillée et un script est lancé dès qu'un fichier s'y trouve ajouté. Ce script encode les vidéos dans les formats requis et génère un document HTML présentant la vidéo à l'aide de l'élément HTML5 `<video>` et des scripts/styles [videojs](http://videojs.com/). Il copie ensuite l'ensemble des fichiers sur un serveur web.

### Boucle de traitement

  1. Liste les fichiers présents dans la boîte de dépôt (dropbox)
  2. Encode les fichiers dans les formats mp4 et webm et crée un poster à l'aide de ffmpeg
  3. Génère un document HTML par vidéo en utilisant la syntaxe videojs
  4. Copie sur le serveur web les fichiers encodés et le document HTML
  5. Archive les sources sur un autre serveur/volume, sinon sur le serveur web.
  6. Nettoie les fichiers restés en local (Fichiers encodés et sources).
  7. Reliste la boîte de dépôt pour voir si quelque chose de nouveau y est, si oui: goto 2

Un log des opérations effectuées peut être utile

## Design

### Les fichiers doivent être prêts au traitement avant lancement du script

Il n'y a pas de moyen sûr pour savoir si un fichier à bien été copié rien qu'en le regardant. Un notification ou autre élément en provenance du client est nécessaire (Client: celui qui à copié le(s) fichier(s) dans la boîte de dépôt)

Donc plusieurs solutions sont envisageables:

#### Solution 1:

Les fichiers copiés depuis les clients distants arrivent dans un dossier X sur le serveur. Une fois la copie terminée, le client déplace les fichiers dans la `dropbox`. Ce qui déclenche l'execution du script (Qui repasse après avoir terminé ses tâches pour s'assurer qu'il n'y a rien de nouveau avant de quitter).

La copie et le déplacement des fichiers peut éventuellement être automatisé par une application de transfert installée sur la machine du client. La copie serait se ferait alors par ssh (scp ou sftp). Avantage du sftp: *ForceCommand internal-sftp*

La surveillance de la boîte de dépôt `dropbox` est prise en charge par launchd et sa méchanique de *watchpaths*. Un exemple de fichier .plist préparé pour le dev se trouve juste à coté: `ch.unil.hva.plist`.

#### Solution 2:

Les fichiers sont copiés dans la dropbox (inerte) et une deuxième étape permet de séléctionner les fichiers à traiter et de lancer le script. (webapp ou fichier manifest) TODO: Elaborer

### Nettoyage

Une fois la copie vers le serveur web effectuée, les fichiers n'ont plus besoin de rester en local. Ils sont alors sélectivement supprimés. (Fichiers sources dans la `dropbox`, fichiers encodés et documents HTML. Le contenu du dossier X de la solution 1 ne serait pas touché.)

# Problèmes à résoudre / Questions

  - Profils vidéo pour l'encodage (Quelle cible visons-nous: taille, débit, qualité, etc... ): Vérifier!
  - Archiver les sources ailleurs que sur le serveur web? Ou?

# Configuration

Prévoir de pouvoir configurer:

  - Profils utilisés pour l'encodage
  - L'adresse du serveur www (et autres params SSH?)
  - L'adresse du serveur d'archivage (et autres params SSH?)

# TODO

  - "Slugifier" les noms de fichiers en entrée (Pour URLs)
  - Fichier HTML spécifique listant les fichiers présents / traités et leur statut (mis à jour à chaque étape) (Pourrait être utilisé pour lancer la conversion plutôt qu'avec launchd... ?)
  - Réfléchir à implications de tagguer les noms de fichiers en sortie avec date ou trier dans struct. datée (YYYY/MM/JJ) pour permettre doublons de noms
  - Prendre poster à 50% de la vidéo
  - Ajouter métadonnées (Ce qu'on a) dans la template HTML pour info
  - Permettre la génération d'un poster en png
  - Moyen plus efficace de compter les numéros de jobs
  - Centrer ou aligner les liens de téléchargements dans video.rhtml
  - Changelog dès initial release
  