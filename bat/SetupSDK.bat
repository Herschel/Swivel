:user_configuration

:: Default path to AIR SDK if installed using HaxeDevelop.
if not defined AIR_SDK (set AIR_SDK=%HOMEDRIVE%%HOMEPATH%\AppData\Local\HaxeDevelop\Apps\ascsdk\27.0.0)

:validation
if not exist "%AIR_SDK%\bin" goto flexsdk
goto succeed

:flexsdk
echo.
echo ERROR: Path to Air SDK not set.
echo Please set the AIR_SDK environment variable, or install the 
echo AIR SDK + ASC 2.0 Compiler in HaxeDevelop -> Tools -> Install Software.
echo.
if %PAUSE_ERRORS%==1 pause
exit

:succeed
set PATH=%PATH%;%AIR_SDK%\bin

