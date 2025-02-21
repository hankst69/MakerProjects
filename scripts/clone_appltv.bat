@rem Apple TV 3,1 (A1427)
@rem https://github.com/NSSpiral/Blackb0x
@rem https://github.com/synackuk/checkm8-a5
@rem https://github.com/felis/USB_Host_Shield_2.0
@echo off
call "%~dp0\maker_env.bat"

set "_APPLETV_DIR=%MAKER_PROJECTS%\AppleTv"

set "_APPLETV_JB_XCode_DIR=%_APPLETV_DIR%\AppleTV3_JailBreak_Blackb0x"
set "_APPLETV_JB_UnoUsb_DIR=%_APPLETV_DIR%\AppleTV3_JailBreak_checkm8-a5"
set "_APPLETV_JB_UnoHostLib_DIR%_APPLETV_DIR%\ArduinoUno_UsbHostShieldLib2.0"

call "%MAKER_SCRIPTS%\clone_in_folder.bat" "%_APPLETV_JB_XCode_DIR%" "https://github.com/NSSpiral/Blackb0x.git" %*
call "%MAKER_SCRIPTS%\clone_in_folder.bat" "%_APPLETV_JB_UnoUsb_DIR%" "https://github.com/synackuk/checkm8-a5.git" %*
call "%MAKER_SCRIPTS%\clone_in_folder.bat" "%_APPLETV_JB_UnoHostLib_DIR%" "https://github.com/felis/USB_Host_Shield_2.0.git" %*

cd /d "%_APPLETV_DIR%"
