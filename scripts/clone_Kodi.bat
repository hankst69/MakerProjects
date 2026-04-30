@rem Kodi
@rem https://kodi.wiki/view/Main_Page
@rem https://kodi.wiki/view/Official_add-on_repository
@echo off
call "%~dp0\maker_env.bat"

@rem https://github.com/xbmc/xbmc.git
@rem https://github.com/xbmc/repo-plugins.git
@rem https://github.com/xbmc/repo-scripts.git

@rem https://kodi.wiki/view/Add-on:Surveillance_Cameras
@rem https://github.com/b-jesch/plugin.video.ipcams/tree/Matrix

@rem https://github.com/zag2me/script.hello.world.git

set "_KODI_DIR=%MAKER_DIR_PROJECTS%\Kodi"

set "_KODI_XBMC_DIR=%_KODI_DIR%\xbmc"
set "_KODI_PLUGINS_DIR=%_KODI_DIR%\plugins"
set "_KODI_SCRIPTS_DIR=%_KODI_DIR%\scripts"
set "_KODI_PLUGINS_IPCAMS_DIR=%_KODI_DIR%\plugin.video.ipcams"
set "_KODI_SCRIPTS_HELLOWORLD_DIR=%_KODI_DIR%\script.hello.world"


rem call "%MAKER_ENV_CORE%\clone_in_folder.bat" "%_KODI_XBMC_DIR%" "https://github.com/xbmc/xbmc.git" %* --switchBranch Helix
call "%MAKER_ENV_CORE%\clone_in_folder.bat" "%_KODI_PLUGINS_DIR%" "https://github.com/xbmc/repo-plugins.git" %* --switchBranch helix
call "%MAKER_ENV_CORE%\clone_in_folder.bat" "%_KODI_SCRIPTS_DIR%" "https://github.com/xbmc/repo-scripts.git" %* --switchBranch helix
call "%MAKER_ENV_CORE%\clone_in_folder.bat" "%_KODI_PLUGINS_IPCAMS_DIR%" "https://github.com/b-jesch/plugin.video.ipcams.git" --switchBranch Matrix
call "%MAKER_ENV_CORE%\clone_in_folder.bat" "%_KODI_SCRIPTS_HELLOWORLD_DIR%" "https://github.com/zag2me/script.hello.world.git"

cd /d "%_KODI_DIR%"
