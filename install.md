# Installation

## Développement

App: `~/work/hva/hva.rb`  
Dropbox: `~/work/hva/dropbox/`  
Outbox: `~/work/hva/outbox/`
Launchd job file: `~/Library/LaunchAgents/ch.unil.hva.plist`  

    cp ch.unil.hva.plist ~/Library/LaunchAgents/
    launchctl load ~/Library/LaunchAgents/ch.unil.hva.plist

## Production

App: `/usr/local/bin/hva.rb`  
Dropbox: `/var/hva/dropbox/`
Outbox: `/var/hva/outbox/`
Launchd job file: `/Library/LaunchDaemons/ch.unil.hva.plist`  

    sudo cp hva.rb /usr/local/bin
    sudo mkdir -p /var/hva/arrival /var/hva/dropbox /var/hva/outbox
    sudo cp hva.conf /etc/hva.conf
    sudo cp ch.unil.hva.plist /Library/LaunchDaemons/
    # Configurer le job launchd et hva.conf
    sudo launchctl load /Library/LaunchDaemons/ch.unil.hva.plist
