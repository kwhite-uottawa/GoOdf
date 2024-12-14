#!/bin/bash

# tested on an image from https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-armhf.img (fails to run on RPi Raspbian)
# try                     https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-armhf.img (fails to boot)
# try building on alpine build environment that I had setup for mpd builds "fossil ui /tmp/msdos/mpd/mpd-flac.fossil"
# running in a FreBSD jail running qemu7-system-arm

set -e

sudo apt update

sudo DEBIAN_FRONTEND=noninteractive apt-get install -y build-essential cmake \
  libwxgtk3.0-gtk3-dev imagemagick \
  pkgconf libfuse2 \
  git wget yaru-theme-icon

# linuxdeploy, linuxdeploy-plugin-gtk and appimagetool must be downloaded
sudo wget -P /usr/local/bin https://raw.githubusercontent.com/linuxdeploy/linuxdeploy-plugin-gtk/master/linuxdeploy-plugin-gtk.sh
sudo wget -P /usr/local/bin https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-armhf.AppImage
sudo wget -P /usr/local/bin https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-armhf.AppImage

# make them executable
sudo chmod +x /usr/local/bin/linuxdeploy-plugin-gtk.sh
sudo chmod +x /usr/local/bin/linuxdeploy-armhf.AppImage
sudo chmod +x /usr/local/bin/appimagetool-armhf.AppImage

exit 0

=== cmake command line? ===

cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr
make -j2 install DESTDIR=AppDir VERBOSE=1
DEPLOY_GTK_VERSION=3 APPIMAGE_EXTRACT_AND_RUN=1 \
	linuxdeploy-armhf.AppImage --appdir AppDir -e ./AppDir/usr/bin/GoOdf \
	-d ./AppDir/usr/share/GoOdf/applications/GoOdf.desktop -i ./AppDir/usr/share/icons/hicolor/256x256/apps/GoOdf.png \
	--plugin gtk
DEPLOY_GTK_VERSION=3 APPIMAGE_EXTRACT_AND_RUN=1 \
        appimagetool-armhf.AppImage --no-appstream AppDir \
	GoOdf-kwhite-`git log --oneline | head -1 | awk '{print $1}'`.armhf.AppImage



=== for release.yml? ===

    - name: Create Appimage
      working-directory: ${{github.workspace}}/build
      run: |
        echo "DEPLOY_GTK_VERSION=3" >> $GITHUB_ENV
        echo "APPIMAGE_EXTRACT_AND_RUN=1" >> $GITHUB_ENV
        linuxdeploy-armhf.AppImage --appdir AppDir -e ./AppDir/usr/bin/GoOdf -d ./AppDir/usr/share/GoOdf/applications/GoOdf.desktop -i ./AppDir/usr/share/icons/hicolor/256x256/apps/GoOdf.png --plugin gtk
        appimagetool-armhf.AppImage --no-appstream AppDir GoOdf-${{env.app_version}}.armhf.AppImage

===
