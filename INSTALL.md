# Installation

## Développement

App: `~/work/hva/bin/hva`  
Config: `~/work/hva/config/config.yml`  
Dropbox: `~/work/hva/dropbox/`  
Outbox: `~/work/hva/public/`  
Launchd job file: `~/Library/LaunchAgents/ch.unil.HTMLVideoAutomator.plist`  

### 1. Install
*(En tant qu'utilisateur)*

    cp ch.unil.HTMLVideoAutomator.plist ~/Library/LaunchAgents/

### 2. Configurer le job launchd et config/config.yml

    nano config/config.yml
    nano ~/Library/LaunchAgents/ch.unil.HTMLVideoAutomator.plist

### 3. Lancer le job launchd

    launchctl load ~/Library/LaunchAgents/ch.unil.HTMLVideoAutomator.plist

## Production

App: `/usr/local/hva/bin/hva`  
Config: `/etc/hva.config.yml`  
Dropbox: `/var/hva/dropbox/`  
Outbox: `/tmp/hva/outbox/`  
Launchd job file: `/Library/LaunchDaemons/ch.unil.HTMLVideoAutomator.plist`  

### 1. Install
*(Toujours en tant que root)*

    mkdir /usr/local/hva/
    cp -R bin lib views README.md /usr/local/hva/
    mkdir -p /var/hva/dropbox /tmp/hva/outbox
    cp config/config.yml /etc/hva.config.yml
    cp ch.unil.HTMLVideoAutomator.plist /Library/LaunchDaemons/

### 2. Configurer le job launchd et hva.config.yml

    nano /etc/hva.config.yml
    nano /Library/LaunchDaemons/ch.unil.HTMLVideoAutomator.plist

### 3. Lancer le job launchd

    launchctl load /Library/LaunchDaemons/ch.unil.hva.plist
