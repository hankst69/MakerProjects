@rem Apple TV 3,1 (A1427)
@rem https://github.com/NSSpiral/Blackb0x
@rem https://github.com/synackuk/checkm8-a5
@rem https://github.com/felis/USB_Host_Shield_2.0
@rem https://github.com/axi0mX/ipwndfu
@rem
@rem https://github.com/NSSpiral/Blackb0x
@rem https://github.com/hankst69/checkm8-a5.git
@rem https://github.com/hankst69/USB_Host_Shield_2.0.git
@echo off
call "%~dp0\maker_env.bat"

set "_APPLETV_DIR=%MAKER_DIR_PROJECTS%\AppleTv"

set "_APPLETV_JB_XCode_DIR=%_APPLETV_DIR%\AppleTV3_JailBreak_Blackb0x"
set "_APPLETV_JB_UnoUsb_DIR=%_APPLETV_DIR%\checkm8-a5"
set "_APPLETV_JB_IPWNDFU_DIR=%_APPLETV_DIR%\ipwndfu"

call "%MAKER_ENV_CORE%\clone_in_folder.bat" "%_APPLETV_JB_XCode_DIR%" "https://github.com/hankst69/Blackb0x.git" %*
rem add startergo as remote (current open PR with Readme update)
cd /d "%_APPLETV_JB_XCode_DIR%"
call git remote add startergo https://github.com/startergo/Blackb0x.git
call git pull startergo


call "%MAKER_ENV_CORE%\clone_in_folder.bat" "%_APPLETV_JB_UnoUsb_DIR%" "https://github.com/hankst69/checkm8-a5.git" %*
rem set "_APPLETV_JB_UnoHostLib_DIR=%_APPLETV_DIR%\ArduinoUno_UsbHostShieldLib2.0"
rem call "%MAKER_ENV_CORE%\clone_in_folder.bat" "%_APPLETV_JB_UnoHostLib_DIR%" "https://github.com/felis/USB_Host_Shield_2.0.git" %*
rem todo: automatically patch the downloaded usb_host_shield_lib with usb_host_library.patch from checkm8-a5 ... 

call "%MAKER_ENV_CORE%\clone_in_folder.bat" "%_APPLETV_JB_IPWNDFU_DIR%" "https://github.com/axi0mX/ipwndfu.git" %*

cd /d "%_APPLETV_DIR%"
