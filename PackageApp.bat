@echo off
set PAUSE_ERRORS=1
call bat\SetupSDK.bat
call bat\SetupApplication.bat

set AIR_TARGET=
set OPTIONS=
call bat\Packager.bat

echo. 2>bin\Swivel\META-INF\AIR\debug
