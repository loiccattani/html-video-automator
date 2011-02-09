# Installation

## prérequis

- Un machine ou serveur puissant (HVA) pour l'application HVA avec (Versions min):
  - Mac OS X 10.6
  - ruby 1.9
  - Apache 2
- Un serveur web (www) pour la publication du contenu

### Optionnel:

- Un serveur d'archivage pour la sauvegarde des sources.

Sinon utiliser le serveur web

## Marche à suivre

- Copier le dossier hva à un endroit adéquat (p.ex. Prod: /var/hva Dev: ~/work/hva)
- Configurer hva/config/config.yml
- Configurer apache sur HVA pour que le DocumentRoot pointe sur hva/public
- Générer si besoin paire de clés ssh et copier la clé publique sur le(s) serveur(s) de publication et d'archivage
