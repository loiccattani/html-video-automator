# Install

Unfortunately there is no easy one-step install wizard... You'll need to get your hands a bit dirty. But, if you already got at least 2 web servers running, it should be pretty straight-forward.

## Prerequisites

You need to have strong knowledge about *nix systems, command-line tools, security and web server setup.

### Servers

- A *main* "HVA" server for the HTML Video Automator application (A powerful one). With:
  - Ruby 1.9.2 or later
  - Apache 2.2 with mod_rewrite and suEXEC properly configured
  - ffmpeg 0.6.1 or later with these libs:
    - libfaac 1.28 or later
    - libvpx 0.9.6 or later
    - libogg 1.2.2 or later
    - libvorbis 1.3.2 or later
    - libtheora 1.1.1 or later
- A *content* server for web publishing

Optional:

- A *sources* server to archive source video files

### HVA server configuration

To do things the right way, the *main* server will likely need a specific username to run the app. Typically, it may be named `hva` and belong to a `www_admins` group. This user will be handed the app's execution by suEXEC at each request.

This is needed for security reasons. But it also comes handy to have a place where to put the SSH key pair used to connect with the *content* and *sources* servers.

### SSH with public key authentication

HTML Video Automator use the `scp` command with SSH public key anthentication to publish and archive files to *content* and *sources* servers respectively.

You'll need a SSH key pair on the *main* server. The public key have to be installed on the *content* and *sources* servers.

You may also want to tighten up your servers security by configuring sshd to accept only public key anthentication. Even accepting only specific users.

## Install the HVA app on the main server

### Copy the app's directory and set permissions

Install the HVA app's directory in an appropriate location. For example, Prod: `/var/www/html-video-automator`, Dev: `~/work/hva`.

1. cd `/var/www`
2. Either download source or clone the git repo: `git clone git://github.com/Arko/html-video-automator.git`
3. Set proper permissions
  - `chgrp -R www_admins html-video-automator`
  - `chmod -R g+w html-video-automator`
4. Remove write permission on `public/dropbox` (Security, required by suEXEC)
  - `chmod g-w html-video-automator/public/dropbox`

### Configure HTML Video Automator

1. Copy the default configuration file `config/config.yml.default` to `config/config.yml`
2. Set any value that needs to be changed, like:
  - `home` to the HVA app's location (In this example: `/var/www/html-video-automator`)
  - `app_root_url` to the public access URL to the HVA main server, pointing to `public`
  - `pub_url` to the *content* server's public access URL where the files will be published
  - `ssh_key` to the private key name used to SSH in the *content* and *sources* servers
  - `content_server` and `sources_server` sections

### Configure the web server

Configure Apache to serve the `public` directory as the DocumentRoot.

SuEXEC is used to specify a who user runs the app.

#### Example of virtual host configuration
    <VirtualHost *:80>
    	ServerName hva.example.com
    	DocumentRoot '/var/www/html-video-automator/public'
    	<Directory '/var/www/html-video-automator/public'>
          AddHandler cgi-script .rb
          Options +ExecCGI
          Order allow,deny
          Allow from all
          AllowOverride All
      </Directory>
      SuexecUserGroup hva www_admins
    </VirtualHost>

# Notes about HVA server set-up and install from sources

This section is a bit off-topic. But if you need to install a new server from scratch, it may pave your way.

This has been done on a 2011 Mac Pro Server 12-core 2.66Ghz Intel Xeon with Mac OS X Snow Leopard Server 10.6.7.

After initial server setup (FW Config, User and groups, sshd config, sudoers, etc...), install:

  - [git 1.7.4](http://git-scm.com/)
  - Xcode 3.2.6 (Needed on Mac OS X to be able to compile software from sources.)
  - [ruby 1.9.2p180 ](http://www.ruby-lang.org/fr/)
  - [Apache 2.2.17](http://httpd.apache.org/docs/2.2/) with suEXEC (More information below)
  - [Yasm](http://www.tortall.net/projects/yasm/) (To compile libvpx, libx264 and ffmpeg with cpu specific optimisations)
  - [libmp3lame](http://lame.sourceforge.net/) Not needed atm, but may be useful later
  - [libfaac 1.28](http://www.audiocoding.com/faac.html) (Download the bootstrapped package)
  - [libvpx 0.9.6](http://code.google.com/p/webm/)
  - [x264](http://www.videolan.org/developers/x264.html) latest snapshot
  - [libogg 1.2.2](http://www.xiph.org/downloads/)
  - [libvorbis 1.3.2](http://www.xiph.org/downloads/)
  - [libtheora 1.1.1](http://www.xiph.org/downloads/)
  - [ffmpeg](http://www.ffmpeg.org/download.html) latest snapshot

## Compiling Apache from source with suEXEC

For security reasons, suEXEC need to be configured at compile time with restrictive settings, such as the caller ID and document root from which suEXEC can be used. Don't forget to modify these in the `configure` command below.

    ./configure --enable-mods-shared=all --enable-suexec --with-suexec-caller=_www --with-suexec-docroot=/var/www

For more information, see: [http://httpd.apache.org/docs/2.2/suexec.html](http://httpd.apache.org/docs/2.2/suexec.html)

Note: Don't forget to do a `make clean` if any suexec configuration setting is changed. Otherwise suexec won't be recompiled with these new settings.

## Compiling FFmpeg

This is how i have configured FFmpeg to work with my setup.

    ./configure --enable-static --disable-shared --enable-gpl --enable-version3 --enable-nonfree --enable-postproc --enable-pthreads --enable-libfaac --enable-libmp3lame --enable-libtheora --enable-libvorbis --enable-libvpx --enable-libx264 --arch=x86_64


