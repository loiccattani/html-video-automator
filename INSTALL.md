# Install

## Prerequisites

- HVA server: A powerful computer or server to host the HVA app. With:
  - Ruby 1.9 or later
  - Apache 2.2
  - ffmpeg 0.6.1 or later
- Content server: A web server to publish content

### Optional:

- Sources server: A data server to archive sources

### SSH with public-key authentication

The *content* and *sources* server must be configured with SSH public-key authentication from the HVA server.

## How to install

On the HVA server:

- Install the HVA app directory in an appropriate location (i.e. Prod: /usr/local/hva, Dev: ~/work/hva)
- Configure hva/config/config.yml
- Configure Apache to serve hva/public as the DocumentRoot
- Generate a new ssh key pair if needed and copy the public-key to the *content* and *sources* server.
