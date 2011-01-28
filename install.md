# Installation

## Développement

Bash script: `~/work/hva/hva`  
Dropbox: `~/work/hva/dropbox/`  
Launchd job file: `~/Library/LaunchAgents/ch.unil.hva.plist`  

    cp ch.unil.hva.plist ~/Library/LaunchAgents/
    launchctl load ~/Library/LaunchAgents/ch.unil.hva.plist

## Production

Avant d'installer en production:

  1. Configurer le job launchd avec les chemins correct du script et de la dropbox
  2. Configurer hva `sudo cp hva.conf /etc/hva.conf` (voir hva.conf)

Bash script: `/usr/local/bin/hva`  
Dropbox: `/var/hva/dropbox/`
Dropbox: `/var/hva/dropbox/`
Launchd job file: `/Library/LaunchDaemons/ch.unil.hva.plist`  

    sudo cp hva /usr/local/bin
    sudo mkdir -p /var/hva/dropbox
    sudo cp ch.unil.hva.plist /Library/LaunchDaemons/
    sudo launchctl load /Library/LaunchDaemons/ch.unil.hva.plist
