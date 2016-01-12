# Deluge Windows installer script
# Version 0.6 22-Nov-2012

# Copyright (C) 2009 by
#   Jesper Lund <mail@jesperlund.com>
#   Andrew Resch <andrewresch@gmail.com>
#   John Garland <johnnybg@gmail.com>

# Deluge is free software.
#
# You may redistribute it and/or modify it under the terms of the
# GNU General Public License, as published by the Free Software
# Foundation; either version 3 of the License, or (at your option)
# any later version.
#
# Deluge is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with deluge.    If not, write to:
# 	The Free Software Foundation, Inc.,
# 	51 Franklin Street, Fifth Floor
# 	Boston, MA    02110-1301, USA.
#

# Script version; displayed when running the installer
!define DELUGE_INSTALLER_VERSION "1.0"

# Deluge program information
!define PROGRAM_NAME "Deluge"
# Detect version from file
!searchparse /file VERSION.tmp `build_version = "` PROGRAM_VERSION `"`
!ifndef PROGRAM_VERSION
   !error "Program Version Undefined"
!endif
!define PROGRAM_WEB_SITE "http://deluge-torrent.org"
!define LICENSE_FILEPATH "..\LICENSE"

# Python files generated with bbfreeze
!define BUILD_DIR "build-win32"
!define BBFREEZE_DIR "${BUILD_DIR}\deluge-bbfreeze-${PROGRAM_VERSION}"
!define INSTALLER_FILENAME "deluge-${PROGRAM_VERSION}-win32-setup.exe"

# Set default compressor
SetCompressor /FINAL /SOLID lzma
SetCompressorDictSize 64

# --- Interface settings ---
# Modern User Interface 2
!include MUI2.nsh
# Installer
!define MUI_ICON "..\deluge\data\pixmaps\deluge.ico"
!define MUI_HEADERIMAGE
!define MUI_HEADERIMAGE_RIGHT
!define MUI_HEADERIMAGE_BITMAP "installer-top.bmp"
!define MUI_WELCOMEFINISHPAGE_BITMAP "installer-side.bmp"
!define MUI_COMPONENTSPAGE_SMALLDESC
!define MUI_FINISHPAGE_NOAUTOCLOSE
!define MUI_ABORTWARNING
# Start Menu Folder Page Configuration
!define MUI_STARTMENUPAGE_DEFAULTFOLDER ${PROGRAM_NAME}
!define MUI_STARTMENUPAGE_REGISTRY_ROOT "HKCR"
!define MUI_STARTMENUPAGE_REGISTRY_KEY "Software\Deluge"
!define MUI_STARTMENUPAGE_REGISTRY_VALUENAME "Start Menu Folder"
# Uninstaller
!define MUI_UNICON "${NSISDIR}\Contrib\Graphics\Icons\modern-uninstall.ico"
!define MUI_HEADERIMAGE_UNBITMAP "installer-top.bmp"
!define MUI_WELCOMEFINISHPAGE_UNBITMAP "installer-side.bmp"
!define MUI_UNFINISHPAGE_NOAUTOCLOSE

!define MUI_FINISHPAGE_SHOWREADME ""
!define MUI_FINISHPAGE_SHOWREADME_NOTCHECKED
!define MUI_FINISHPAGE_SHOWREADME_TEXT "Create Desktop Shortcut"
!define MUI_FINISHPAGE_SHOWREADME_FUNCTION finishpageaction

# --- Start of Modern User Interface ---
Var StartMenuFolder
# Welcome, License & Components pages
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE ${LICENSE_FILEPATH}
!insertmacro MUI_PAGE_COMPONENTS
# Let the user select the installation directory
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_STARTMENU Application $StartMenuFolder
# Run installation
!insertmacro MUI_PAGE_INSTFILES
# Popup Message if VC Redist missing
Page Custom VCRedistMessage
# Display 'finished' page
!insertmacro MUI_PAGE_FINISH
# Uninstaller pages
!insertmacro MUI_UNPAGE_INSTFILES
# Language files
!insertmacro MUI_LANGUAGE "English"


# --- Functions ---

# Check for running Deluge instance.
Function .onInit
    System::Call 'kernel32::OpenMutex(i 0x100000, b 0, t "deluge") i .R0'
    IntCmp $R0 0 notRunning
        System::Call 'kernel32::CloseHandle(i $R0)'
        MessageBox MB_OK|MB_ICONEXCLAMATION "Deluge is running. Please close it first" /SD IDOK
        Abort
    notRunning:
FunctionEnd

Function un.onUninstSuccess
    HideWindow
    MessageBox MB_ICONINFORMATION|MB_OK "$(^Name) was successfully removed from your computer." /SD IDOK
FunctionEnd

Function un.onInit
    MessageBox MB_ICONQUESTION|MB_YESNO|MB_DEFBUTTON2 "Do you want to completely remove $(^Name)?" /SD IDYES IDYES +2
    Abort
FunctionEnd

Function finishpageaction
    CreateShortCut "$DESKTOP\Deluge.lnk" "$INSTDIR\deluge.exe"
FunctionEnd

# Test if Visual Studio Redistributables 2008 SP1 installed and returns -1 if none installed
Function CheckVCRedist2008
    Push $R0
    ClearErrors
    ReadRegDword $R0 HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{FF66E9F6-83E7-3A3E-AF14-8DE9A809A6A4}" "Version"
    IfErrors 0 +2
        StrCpy $R0 "-1"

    Push $R1
    ClearErrors
    ReadRegDword $R1 HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{9BE518E6-ECC6-35A9-88E4-87755C07200F}" "Version"
    IfErrors 0 VSRedistInstalled
        StrCpy $R1 "-1"

    StrCmp $R0 "-1" +3 0
        Exch $R0
        Goto VSRedistInstalled
    StrCmp $R1 "-1" +3 0
        Exch $R1
        Goto VSRedistInstalled
    # else
        Push "-1"
    VSRedistInstalled:
FunctionEnd

Function VCRedistMessage
    Call CheckVCRedist2008
    Pop $R0
    StrCmp $R0 "-1" 0 end
    MessageBox MB_YESNO|MB_ICONEXCLAMATION "Deluge requires an MSVC package to run \
    but the recommended package does not appear to be installed:$\r$\n$\r$\n\
    Microsoft Visual C++ 2008 SP1 Redistributable Package (x86)$\r$\n$\r$\n\
    Would you like to download it now?" /SD IDNO IDYES clickyes
    Goto end
    clickyes:
        ExecShell open "https://www.microsoft.com/en-us/download/details.aspx?id=26368"
    end:
FunctionEnd

# --- Installation sections ---
!define PROGRAM_UNINST_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PROGRAM_NAME}"
!define PROGRAM_UNINST_ROOT_KEY "HKLM"
!define PROGRAM_UNINST_FILENAME "$INSTDIR\deluge-uninst.exe"

BrandingText "${PROGRAM_NAME} Windows Installer v${DELUGE_INSTALLER_VERSION}"
Name "${PROGRAM_NAME} ${PROGRAM_VERSION}"
OutFile "${BUILD_DIR}\${INSTALLER_FILENAME}"
InstallDir "$PROGRAMFILES\Deluge"

ShowInstDetails show
ShowUnInstDetails show

# Install main application
Section "Deluge Bittorrent Client" Section1
    SectionIn RO
    !include "install_files.nsh"

    SetOverwrite ifnewer
    SetOutPath "$INSTDIR"
    File ${LICENSE_FILEPATH}
    WriteIniStr "$INSTDIR\homepage.url" "InternetShortcut" "URL" "${PROGRAM_WEB_SITE}"

    !insertmacro MUI_STARTMENU_WRITE_BEGIN Application
        SetShellVarContext all
        CreateDirectory "$SMPROGRAMS\$StartMenuFolder"
        CreateShortCut "$SMPROGRAMS\$StartMenuFolder\Deluge.lnk" "$INSTDIR\deluge.exe"
        CreateShortCut "$SMPROGRAMS\$StartMenuFolder\Website.lnk" "$INSTDIR\homepage.url"
        CreateShortCut "$SMPROGRAMS\$StartMenuFolder\Uninstall Deluge.lnk" ${PROGRAM_UNINST_FILENAME}
    !insertmacro MUI_STARTMENU_WRITE_END
SectionEnd

# Create .torrent file association.
Section "Associate .torrent files with Deluge" Section2
    DeleteRegKey HKCR ".torrent"
    WriteRegStr HKCR ".torrent" "" "Deluge"
    WriteRegStr HKCR ".torrent" "Content Type" "application/x-bittorrent"

    DeleteRegKey HKCR "Deluge"
    WriteRegStr HKCR "Deluge" "" "Deluge"
    WriteRegStr HKCR "Deluge\Content Type" "" "application/x-bittorrent"
    WriteRegStr HKCR "Deluge\DefaultIcon" "" "$INSTDIR\deluge.exe,0"
    WriteRegStr HKCR "Deluge\shell" "" "open"
    WriteRegStr HKCR "Deluge\shell\open\command" "" '"$INSTDIR\deluge.exe" "%1"'
SectionEnd

# Create magnet uri association.
Section "Associate Magnet URI links with Deluge" Section3
    DeleteRegKey HKCR "Magnet"
    WriteRegStr HKCR "Magnet" "" "URL:Magnet Protocol"
    WriteRegStr HKCR "Magnet" "URL Protocol" ""
    WriteRegStr HKCR "Magnet\shell\open\command" "" '"$INSTDIR\deluge.exe" "%1"'
SectionEnd

LangString DESC_Section1 ${LANG_ENGLISH} "Install Deluge Bittorrent client."
LangString DESC_Section2 ${LANG_ENGLISH} "Select this option to let Deluge handle the opening of .torrent files."
LangString DESC_Section3 ${LANG_ENGLISH} "Select this option to let Deluge handle Magnet URI links from the web-browser."

!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
    !insertmacro MUI_DESCRIPTION_TEXT ${Section1} $(DESC_Section1)
    !insertmacro MUI_DESCRIPTION_TEXT ${Section2} $(DESC_Section2)
    !insertmacro MUI_DESCRIPTION_TEXT ${Section3} $(DESC_Section3)
!insertmacro MUI_FUNCTION_DESCRIPTION_END

# Create uninstaller.
Section -Uninstaller
    WriteUninstaller ${PROGRAM_UNINST_FILENAME}
    WriteRegStr ${PROGRAM_UNINST_ROOT_KEY} "${PROGRAM_UNINST_KEY}" "DisplayName" "$(^Name)"
    WriteRegStr ${PROGRAM_UNINST_ROOT_KEY} "${PROGRAM_UNINST_KEY}" "UninstallString" ${PROGRAM_UNINST_FILENAME}
SectionEnd

# --- Uninstallation section ---
Section Uninstall
    # Delete Deluge files.
    Delete "$INSTDIR\LICENSE"
    Delete "$INSTDIR\homepage.url"
    Delete ${PROGRAM_UNINST_FILENAME}
    !include "uninstall_files.nsh"

    # Delete Start Menu items.
    !insertmacro MUI_STARTMENU_GETFOLDER Application $StartMenuFolder
        SetShellVarContext all
        Delete "$SMPROGRAMS\$StartMenuFolder\Deluge.lnk"
        Delete "$SMPROGRAMS\$StartMenuFolder\Uninstall Deluge.lnk"
        Delete "$SMPROGRAMS\$StartMenuFolder\Deluge Website.lnk"
        RmDir "$SMPROGRAMS\$StartMenuFolder"
        DeleteRegKey /ifempty HKCR "Software\Deluge"

    Delete "$DESKTOP\Deluge.lnk"

    # Delete registry keys.
    DeleteRegKey ${PROGRAM_UNINST_ROOT_KEY} "${PROGRAM_UNINST_KEY}"
    # Only delete the .torrent association if Deluge owns it
    ReadRegStr $1 HKCR ".torrent" ""
    StrCmp $1 "Deluge" 0 DELUGE_skip_delete
        # Delete the key since it is owned by Deluge; afterwards there is no .torrent association
        DeleteRegKey HKCR ".torrent"
    DELUGE_skip_delete:
    # This key is only used by Deluge, so we should always delete it
    DeleteRegKey HKCR "Deluge"
SectionEnd

# Add version info to installer properties.
VIProductVersion "${DELUGE_INSTALLER_VERSION}.0.0"
VIAddVersionKey ProductName ${PROGRAM_NAME}
VIAddVersionKey Comments "Deluge Bittorrent Client"
VIAddVersionKey CompanyName "Deluge Team"
VIAddVersionKey LegalCopyright "Deluge Team"
VIAddVersionKey FileDescription "${PROGRAM_NAME} Application Installer"
VIAddVersionKey FileVersion "${DELUGE_INSTALLER_VERSION}.0.0"
VIAddVersionKey ProductVersion "${PROGRAM_VERSION}.0"
VIAddVersionKey OriginalFilename ${INSTALLER_FILENAME}
