# Installation

## Développement

Bash script: `~/work/hva/hva`  
Launchpad: `~/work/hva/launchpad/`  
Payload: `~/work/hva/payload/`
Launchd job file: `~/Library/LaunchAgents/ch.unil.hva.plist`  

    cp ch.unil.hva.plist ~/Library/LaunchAgents/
    launchctl load ~/Library/LaunchAgents/ch.unil.hva.plist

## Production

Bash script: `/usr/local/bin/hva`  
Launchpad: `/var/hva/launchpad/`
Payload: `/var/hva/payload/`
Launchd job file: `/Library/LaunchDaemons/ch.unil.hva.plist`  

    sudo cp hva /usr/local/bin
    sudo mkdir -p /var/hva/arrival /var/hva/launchpad /var/hva/payload
    sudo cp hva.conf /etc/hva.conf
    sudo cp ch.unil.hva.plist /Library/LaunchDaemons/
    # Configurer le job launchd et hva.conf
    sudo launchctl load /Library/LaunchDaemons/ch.unil.hva.plist
