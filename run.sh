#!/bin/sh
exec podman run -it --rm -e DISPLAY="$DISPLAY" -v ~/.Xauthority:/root/.Xauthority:Z -v /tmp/.X11-unix:/tmp/.X11-unix:Z -v ~/.config/netscape:/root/.netscape:Z --net=host --arch=386 netscape
