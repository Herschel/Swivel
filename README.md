# ![Swivel](https://www.newgrounds.com/imgs/swivel/logo.png)
[![Build Status](https://travis-ci.org/Herschel/Swivel.svg?branch=master)](https://travis-ci.org/Herschel/Swivel)

Converts Adobe Flash SWF files to video.

## Binaries

The latest stable release of Swivel can be found at <https://www.newgrounds.com/wiki/creator-resources/flash-resources/swivel?path=/wiki/creator-resources/flash-resources/swivel>.

## Building from source

Swivel is built using the [Haxe](http://www.haxe.org) programming language.
Run `haxe Swivel.hxml` to build, then run `PackageApp.bat` to package the app.

The current source will have regressions from the binary release on Newgrounds;
I'm trying to get everything working again!

## License

Swivel is licensed under the GNU GPLv3.
See [LICENSE.md](LICENSE.md) for the full license.

Swivel runs using the [Adobe AIR](https://get.adobe.com/air/) runtime. AIR is 
owned by Adobe Systems, Inc.

Swivel uses software from the [FFmpeg](https://www.ffmpeg.org) project along 
with supporting libraries, licensed under their corresponding licenses. These 
libraries include:

bzip2, fontconfig, FreeType, frei0r, gnutls, LAME, libass, libbluray, libcaca,
libgsm, libtheora, libvorbis, libvpx, opencore-amr, openjpeg, opus, rtmpdump,
schroedinger, speez, twolame, vo-aacenc, vo-amrwbenc, libx264, xavs, xvid, zlib

The full licenses for FFmpeg and each library can be found in the [FFmpeg/licenses](FFmpeg/licenses) 
folder. These licenses are compatible with the GPLv3.

FFmpeg and the these libraries are property of their respective owners.
The FFmpeg build bundled in this software was compiled by Kyle Schwarz and
downloaded from <http://ffmpeg.zeranoe.com/builds/>.
