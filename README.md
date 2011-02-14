# HVA - HTML Video Automator

This is a ruby application for automating video conversion and publishing on the web. It uses the HTML5 `<video>` element for browsers supporting it, and provide a Flash fallback for other browsers.

**This project is currently under active development.**  
Beta versions may come pretty soon.

Oh, and you may find some french words here and there. Don't be afraid.

## How it works?

Things have to be simple: Upload some videos in a dropbox, point your browser at the app's url, select one or more videos and hit "Automate!". That's it!

The app take care of the rest and provide you with links to HTML documents presenting your videos.

## How to make it working?

See `INSTALL.md`

## Technology

- Ruby 1.9 as the programming language.
- [FFmpeg](http://ffmpeg.org/) is used for MPEG-4, WebM and Ogg video conversion.
- HTML video playback is powered with the [VideoJS HTML5 Video Player](http://videojs.com/).

# License

See the file `LICENSE`
