;NSIS Modern User Interface
;Welcome/Finish Page Example Script
;Written by Joost Verburg

;--------------------------------
;Include Modern UI

  !include "MUI2.nsh"

;--------------------------------
;General

  ;Name and file
  Name "Swivel"
  OutFile "swivel-win32.exe"

  ;Default installation folder
  InstallDir "$PROGRAMFILES\Swivel"

  ;Get installation folder from registry if available
  InstallDirRegKey HKCU "Software\Swivel" ""

  ;Request application privileges for Windows Vista
  RequestExecutionLevel admin

  SetCompressor /SOLID /FINAL lzma

;--------------------------------
;Variables

  Var StartMenuFolder

Function createDestkopIcon
  CreateShortcut "$DESKTOP\Swivel.lnk" "$INSTDIR\Swivel.exe"
FunctionEnd

;--------------------------------
;Interface Settings

  !define MUI_HEADERIMAGE
  !define MUI_HEADERIMAGE_BITMAP "assets\WinInstallerHeader.bmp"
  !define MUI_ABORTWARNING

;--------------------------------
;Pages

  !insertmacro MUI_PAGE_WELCOME
  !insertmacro MUI_PAGE_LICENSE "LICENSE.md"
  !insertmacro MUI_PAGE_COMPONENTS
  !insertmacro MUI_PAGE_DIRECTORY
  !define MUI_STARTMENUPAGE_REGISTRY_ROOT "HKCU"
  !define MUI_STARTMENUPAGE_REGISTRY_KEY "Software\Swivel"
  !define MUI_STARTMENUPAGE_REGISTRY_VALUENAME "Start Menu Folder"
  !insertmacro MUI_PAGE_STARTMENU Application $StartMenuFolder
  !insertmacro MUI_PAGE_INSTFILES
  !define MUI_FINISHPAGE_RUN "$INSTDIR\Swivel.exe"
  !define MUI_FINISHPAGE_SHOWREADME ""
  !define MUI_FINISHPAGE_SHOWREADME_NOTCHECKED
  !define MUI_FINISHPAGE_SHOWREADME_TEXT "Create Desktop Shortcut"
  !define MUI_FINISHPAGE_SHOWREADME_FUNCTION createDestkopIcon
  !insertmacro MUI_PAGE_FINISH

  !insertmacro MUI_UNPAGE_WELCOME
  !insertmacro MUI_UNPAGE_CONFIRM
  !insertmacro MUI_UNPAGE_INSTFILES
  !insertmacro MUI_UNPAGE_FINISH

;--------------------------------
;Languages

  !insertmacro MUI_LANGUAGE "English"

;--------------------------------
;Installer Sections

Section "Swivel" SecSwivel

  SetOutPath "$INSTDIR"

  File /r bin\Swivel\*

  ;Store installation folder
  WriteRegStr HKCU "Software\Swivel" "" $INSTDIR

  ;Create uninstaller
  WriteUninstaller "$INSTDIR\Uninstall.exe"

  !insertmacro MUI_STARTMENU_WRITE_BEGIN Application
  SetShellVarContext all
  ;Create shortcuts
  CreateDirectory "$SMPROGRAMS\$StartMenuFolder"
  CreateShortCut "$SMPROGRAMS\$StartMenuFolder\Swivel.lnk" "$INSTDIR\Swivel.exe"
  CreateShortCut "$SMPROGRAMS\$StartMenuFolder\Uninstall.lnk" "$INSTDIR\Uninstall.exe"
				
  !insertmacro MUI_STARTMENU_WRITE_END

  ;Add/Remove Programs
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Swivel" \
                 "DisplayName" "Swivel"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Swivel" \
                 "UninstallString" "$\"$INSTDIR\uninstall.exe$\""
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Swivel" \
                 "QuietUninstallString" "$\"$INSTDIR\uninstall.exe$\" /S"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Swivel" \
                 "DisplayIcon" "$\"$INSTDIR\Swivel.exe$\""
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Swivel" \
                 "Publisher" "Newgrounds.com, Inc."
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Swivel" \
                 "HelpLink" "http://www.newgrounds.com"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Swivel" \
                 "DisplayVersion" "1.11"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Swivel" \
                 "VersionMajor" "1"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Swivel" \
                 "VersionMinor" "11"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Swivel" \
                 "NoModify" "1"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Swivel" \
                 "NoRepair" "1"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Swivel" \
                 "EstimatedSize" "61440"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Swivel" \
                 "Comments" "SWF to video convertor"
SectionEnd

;--------------------------------
;Descriptions

  ;Language strings
  LangString DESC_SecSwivel ${LANG_ENGLISH} "Swivel"

  ;Assign language strings to sections
  !insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
    !insertmacro MUI_DESCRIPTION_TEXT ${SecSwivel} $(DESC_SecSwivel)
  !insertmacro MUI_FUNCTION_DESCRIPTION_END

;--------------------------------
;Uninstaller Section

Section "Uninstall"

  ;ADD YOUR OWN FILES HERE...

  Delete "$INSTDIR\Uninstall.exe"

  RMDir /r "$INSTDIR"

  !insertmacro MUI_STARTMENU_GETFOLDER Application $StartMenuFolder
  SetShellVarContext all
  Delete "$SMPROGRAMS\$StartMenuFolder\Uninstall.lnk"
  Delete "$SMPROGRAMS\$StartMenuFolder\Swivel.lnk"
  RMDir /r "$SMPROGRAMS\$StartMenuFolder"

  DeleteRegKey /ifempty HKCU "Software\Swivel"
  DeleteRegKey  HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Swivel"

SectionEnd