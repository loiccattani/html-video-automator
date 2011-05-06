# HVA - HTML Video Automator

Encode your videos in all formats required for HTML5 video playback, generate poster image and HTML5 document, publish all  files to your web server and archive the sources elsewhere. 1-Click.

HTML Video Automator is a ruby application automating video conversion and publishing on the web. It use the HTML5 `<video>` element for browsers supporting it, and provide a Flash fallback for others.

**This project is currently under active development.**  
Beta version may come pretty soon.

Oh, you may find some french words here and there. Don't be afraid.

## How it works?

Upload some videos in the dropbox, point your browser at the app's url, select one or more videos and hit "Automate!".

That's it! The app take care of the rest and provide you with links to HTML documents presenting your videos.

## How to make it working?

See `INSTALL.md`

## Technology

- Ruby 1.9 as the programming language.
- Apache 2.2 as the webserver, with suEXEC
- [FFmpeg](http://ffmpeg.org/), used for MPEG-4, WebM and Ogg video conversion. With libfaac, libvpx, x264, libogg, libvorbis and libtheora.
- HTML video playback is powered with the super compatible [VideoJS HTML5 Video Player](http://videojs.com/).
- [HTML5 Boilerplate](http://html5boilerplate.com/) for HTML5 awesome.

# License

See the file `LICENSE`
