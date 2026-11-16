#!/usr/bin/env zsh

cd "$(dirname "$0")"

if [ -z "$AIR_SDK" ]
then
    echo .
    echo ERROR: Path to Air SDK not set.
    echo Please set the AIR_SDK environment variable.
    echo .
else
    mkdir -p ./bin/ffmpeg
    lipo -create ./ffmpeg/mac64/ffmpeg_arm64 ./ffmpeg/mac64/ffmpeg_x86_64 -o ./bin/ffmpeg/ffmpeg
    $AIR_SDK/bin/adt -package -storetype pkcs12 -keystore bat/Swivel.p12 -storepass ngswivel\!430 -target bundle bin/Swivel application.xml bin/Swivel.swf bin/ffmpeg ffmpeg/licenses assets/icons README.md LICENSE.md
fi