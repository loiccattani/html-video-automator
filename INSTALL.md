# Install

Unfortunately there is no easy one-step install wizard... You'll need to get your hands a bit dirty. But, if you already got at least 2 web servers running, it should be pretty straight-forward.

## Prerequisites

- A *main* server for the HTML Video Automator application (A powerful one). With:
  - Ruby 1.9.2 or later
  - Apache 2.2 with mod_rewrite and suEXEC properly configured
  - ffmpeg 0.6.1 or later #TODO: Specify external libraries used and configure options
- A *content* server for web publishing

### Optional:

- A *sources* server to archive source video files

### SSH with public key authentication

HTML Video Automator use `scp` with SSH public key anthentication to publish and archive files to *content* and *sources* servers.

You will need to generate a new ssh key pair – if needed – and copy your public key to the *content* and *sources* servers.

You may also want to tighten up your servers security by configuring sshd to accept only public key anthentication. Even accepting only specific users. For more information, Google is your friend.

## Install the HVA app on the main server

### Copy the app's directory

Install the HVA app's directory in an appropriate location (i.e. Prod: `/var/www/html-video-automator`, Dev: `~/work/hva`)

No stable release for now:

1. cd `/var/www`
2. Either download source or clone the git repo: `git clone git://github.com/Arko/html-video-automator.git`

### Configure HTML Video Automator

Edit the file `config/config.yml` and set any value needed, at least:

- `home` needs to be the same as HVA app's location
- `app_root_url` to the public access URL to the HVA main server
- `pub_url` to the public access URL where the files will be published
- `ssh_key` to the private key name used to SSH in the *content* and *sources* servers
- `content_server` and `sources_server` sections

### Configure the web server

Configure Apache to serve the `public` directory as the DocumentRoot.

SuEXEC is used to specify which user runs the app. This is needed mainly for security reasons, but it comes handy to have a place where to put the SSH private key used to connect with other servers.

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

#### Compiling Apache from source with suEXEC

A little off-topic but can be useful:

For security reasons suEXEC need to be configured at compile time with restrictive settings, such as the caller ID and document root from which suEXEC can be used. Don't forget to modify these in the `configure` command below.

`./configure --enable-mods-shared=all --enable-suexec --with-suexec-caller=www --with-suexec-docroot=/var/www`

For more information, see: [http://httpd.apache.org/docs/2.2/suexec.html](http://httpd.apache.org/docs/2.2/suexec.html)
