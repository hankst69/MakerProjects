@rem Kodi
@echo off
call "%~dp0\maker_env.bat"

@rem https://kodi.wiki/view/Main_Page
@rem https://kodi.wiki/view/Official_add-on_repository
@:: https://github.com/xbmc/xbmc.git
@:: https://github.com/xbmc/repo-plugins.git
@:: https://github.com/xbmc/repo-scripts.git

@rem https://kodi.wiki/view/Add-on:Surveillance_Cameras
@:: https://github.com/b-jesch/plugin.video.ipcams

@rem https://kodi.tv/addons/omega/plugin.video.ted.talks/
@:: https://github.com/moreginger/xbmc-plugin.video.ted.talks
@:: https://mirrors.kodi.tv/addons/helix/script.module.elementtree/script.module.elementtree-1.2.8.zip
@:: https://mirrors.kodi.tv/addons/helix/script.module.parsedom/script.module.parsedom-2.5.2.zip

@rem https://kodi.wiki/view/HOW-TO:HelloWorld_addon
@:: https://github.com/zag2me/script.hello.world

@:: https://github.com/hankst69/kodi-addons.script.hello.world
@:: https://github.com/hankst69/kodi-addons.plugin.video.ipcams
@:: https://github.com/hankst69/kodi-addons.plugin.video.ted.talks


set "_KODI_DIR=%MAKER_DIR_PROJECTS%\Kodi"

set "_KODI_XBMC_DIR=%_KODI_DIR%\xbmc"
set "_KODI_PLUGINS_DIR=%_KODI_DIR%\plugins"
set "_KODI_SCRIPTS_DIR=%_KODI_DIR%\scripts"
set "_KODI_MYADDONS_DIR=%_KODI_DIR%\myhelix_addons"

set "_KODI_SCRIPT_HELLOWORLD_DIR=%_KODI_MYADDONS_DIR%\script.hello.world"
set "_KODI_PLUGIN_IPCAMS_DIR=%_KODI_MYADDONS_DIR%\plugin.video.ipcams"
set "_KODI_PLUGIN_TED_DIR=%_KODI_MYADDONS_DIR%\plugin.video.ted.talks"


rem call "%MAKER_ENV_CORE%\clone_in_folder.bat" "%_KODI_XBMC_DIR%" "https://github.com/xbmc/xbmc.git" %* --switchBranch Helix
call "%MAKER_ENV_CORE%\clone_in_folder.bat" "%_KODI_PLUGINS_DIR%" "https://github.com/xbmc/repo-plugins.git" %* --switchBranch helix
call "%MAKER_ENV_CORE%\clone_in_folder.bat" "%_KODI_SCRIPTS_DIR%" "https://github.com/xbmc/repo-scripts.git" %* --switchBranch helix

call "%MAKER_ENV_CORE%\clone_in_folder.bat" "%_KODI_SCRIPT_HELLOWORLD_DIR%" "https://github.com/hankst69/kodi-addons.script.hello.world.git"
call "%MAKER_ENV_CORE%\clone_in_folder.bat" "%_KODI_PLUGIN_IPCAMS_DIR%" "https://github.com/hankst69/kodi-addons.plugin.video.ipcams.git" --switchBranch Helix
call "%MAKER_ENV_CORE%\clone_in_folder.bat" "%_KODI_PLUGIN_TED_DIR%" "https://github.com/hankst69/kodi-addons.plugin.video.ted.talks.git" --switchBranch helix

call curl -o "%_KODI_MYADDONS_DIR%\script.module.elementtree-1.2.8.zip" "https://mirrors.kodi.tv/addons/helix/script.module.elementtree/script.module.elementtree-1.2.8.zip"
echo curl -o "%_KODI_MYADDONS_DIR%\script.module.elementtree-1.2.8.zip" "https://mirrors.kodi.tv/addons/helix/script.module.elementtree/script.module.elementtree-1.2.8.zip"
call curl -o "%_KODI_MYADDONS_DIR%\script.module.parsedom-2.5.2.zip" "https://mirrors.kodi.tv/addons/helix/script.module.parsedom/script.module.parsedom-2.5.2.zip"
echo curl -o "%_KODI_MYADDONS_DIR%\script.module.parsedom-2.5.2.zip" "https://mirrors.kodi.tv/addons/helix/script.module.parsedom/script.module.parsedom-2.5.2.zip"

set "_KODY_PACK_MYADDONS=%_KODI_MYADDONS_DIR%\pack.bat"

echo.@echo off >"%_KODY_PACK_MYADDONS%"
echo.cd /d "%_KODI_MYADDONS_DIR%" >>"%_KODY_PACK_MYADDONS%"
echo.call 7z a -tzip plugin.video.ipcams.zip plugin.video.ipcams -x!plugin.video.ipcams\.git* -x!plugin.video.ipcams\.vs* >>"%_KODY_PACK_MYADDONS%"
echo.call 7z a -tzip plugin.video.ted.talks.zip plugin.video.ted.talks -x!plugin.video.ted.talks\.git* -x!plugin.video.ted.talks\.vs* >>"%_KODY_PACK_MYADDONS%"
echo.call 7z a -tzip script.hello.world.zip script.hello.world -x!script.hello.world\.git* -x!script.hello.world\.vs* >>"%_KODY_PACK_MYADDONS%"

cd /d "%_KODI_MYADDONS_DIR%"
