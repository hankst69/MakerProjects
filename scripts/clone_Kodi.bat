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
call "%MAKER_ENV_CORE%\clone_in_folder.bat" "%_KODI_PLUGIN_IPCAMS_DIR%"     "https://github.com/hankst69/kodi-addons.plugin.video.ipcams.git" --switchBranch Helix
call "%MAKER_ENV_CORE%\clone_in_folder.bat" "%_KODI_PLUGIN_TED_DIR%"        "https://github.com/hankst69/kodi-addons.plugin.video.ted.talks.git" --switchBranch helix

echo curl -o "%_KODI_MYADDONS_DIR%\script.module.elementtree-1.2.8.zip" "https://mirrors.kodi.tv/addons/helix/script.module.elementtree/script.module.elementtree-1.2.8.zip"
echo curl -o "%_KODI_MYADDONS_DIR%\script.module.parsedom-2.5.2.zip"    "https://mirrors.kodi.tv/addons/helix/script.module.parsedom/script.module.parsedom-2.5.2.zip"
echo curl -o "%_KODI_MYADDONS_DIR%\plugin.video.ted.talks-4.2.12.zip"   "https://mirrors.kodi.tv/addons/helix/plugin.video.ted.talks/plugin.video.ted.talks-4.2.12.zip"
echo "https://mirrors.kodi.tv/addons/helix/" -^> "https://ftp.fau.de/xbmc/addons/helix/"
call curl -o "%_KODI_MYADDONS_DIR%\script.module.elementtree-1.2.8.zip" "https://ftp.fau.de/xbmc/addons/helix/script.module.elementtree/script.module.elementtree-1.2.8.zip"
call curl -o "%_KODI_MYADDONS_DIR%\script.module.parsedom-2.5.2.zip"    "https://ftp.fau.de/xbmc/addons/helix/script.module.parsedom/script.module.parsedom-2.5.2.zip"
call curl -o "%_KODI_MYADDONS_DIR%\plugin.video.ted.talks-4.2.12.zip"   "https://ftp.fau.de/xbmc/addons/helix/plugin.video.ted.talks/plugin.video.ted.talks-4.2.12.zip"

set "_KODY_PACK_MYADDONS=%_KODI_MYADDONS_DIR%\pack.bat"

echo.@echo off >"%_KODY_PACK_MYADDONS%"
echo.cd /d "%_KODI_MYADDONS_DIR%" >>"%_KODY_PACK_MYADDONS%"
echo.call 7z a -tzip plugin.video.ipcams.zip plugin.video.ipcams -x!plugin.video.ipcams\.git* -x!plugin.video.ipcams\.vs* >>"%_KODY_PACK_MYADDONS%"
echo.call 7z a -tzip plugin.video.ted.talks.zip plugin.video.ted.talks -x!plugin.video.ted.talks\.git* -x!plugin.video.ted.talks\.vs* >>"%_KODY_PACK_MYADDONS%"
echo.call 7z a -tzip script.hello.world.zip script.hello.world -x!script.hello.world\.git* -x!script.hello.world\.vs* >>"%_KODY_PACK_MYADDONS%"

cd /d "%_KODI_MYADDONS_DIR%"
goto :EOF

/Applications/Kodi.frappliance -> /Applications/AppleTV.app/Appliances/Kodi.frappliance

/Applications/Kodi.frappliance/AppData/AppHome/addons/audioencoder.flac/addon.xml
/Applications/Kodi.frappliance/AppData/AppHome/addons/audioencoder.lame/addon.xml
/Applications/Kodi.frappliance/AppData/AppHome/addons/audioencoder.vorbis/addon.xml
/Applications/Kodi.frappliance/AppData/AppHome/addons/audioencoder.wav/addon.xml
/Applications/Kodi.frappliance/AppData/AppHome/addons/audioencoder.xbmc.builtin.aac/addon.xml
/Applications/Kodi.frappliance/AppData/AppHome/addons/audioencoder.xbmc.builtin.wma/addon.xml
/Applications/Kodi.frappliance/AppData/AppHome/addons/metadata.album.universal/addon.xml
/Applications/Kodi.frappliance/AppData/AppHome/addons/metadata.artists.universal/addon.xml
/Applications/Kodi.frappliance/AppData/AppHome/addons/metadata.common.allmusic.com/addon.xml
/Applications/Kodi.frappliance/AppData/AppHome/addons/metadata.common.amazon.de/addon.xml
/Applications/Kodi.frappliance/AppData/AppHome/addons/metadata.common.fanart.tv/addon.xml
/Applications/Kodi.frappliance/AppData/AppHome/addons/metadata.common.hdtrailers.net/addon.xml
/Applications/Kodi.frappliance/AppData/AppHome/addons/metadata.common.htbackdrops.com/addon.xml
/Applications/Kodi.frappliance/AppData/AppHome/addons/metadata.common.imdb.com/addon.xml
/Applications/Kodi.frappliance/AppData/AppHome/addons/metadata.common.last.fm/addon.xml
/Applications/Kodi.frappliance/AppData/AppHome/addons/metadata.common.musicbrainz.org/addon.xml
/Applications/Kodi.frappliance/AppData/AppHome/addons/metadata.common.theaudiodb.com/addon.xml
/Applications/Kodi.frappliance/AppData/AppHome/addons/metadata.common.themoviedb.org/addon.xml
/Applications/Kodi.frappliance/AppData/AppHome/addons/metadata.local/addon.xml
/Applications/Kodi.frappliance/AppData/AppHome/addons/metadata.musicvideos.theaudiodb.com/addon.xml
/Applications/Kodi.frappliance/AppData/AppHome/addons/metadata.themoviedb.org/addon.xml
/Applications/Kodi.frappliance/AppData/AppHome/addons/metadata.tvdb.com/addon.xml
/Applications/Kodi.frappliance/AppData/AppHome/addons/pvr.argustv/addon.xml
/Applications/Kodi.frappliance/AppData/AppHome/addons/pvr.demo/addon.xml
/Applications/Kodi.frappliance/AppData/AppHome/addons/pvr.dvblink/addon.xml
/Applications/Kodi.frappliance/AppData/AppHome/addons/pvr.dvbviewer/addon.xml
/Applications/Kodi.frappliance/AppData/AppHome/addons/pvr.filmon/addon.xml
/Applications/Kodi.frappliance/AppData/AppHome/addons/pvr.hts/addon.xml
/Applications/Kodi.frappliance/AppData/AppHome/addons/pvr.iptvsimple/addon.xml
/Applications/Kodi.frappliance/AppData/AppHome/addons/pvr.mediaportal.tvserver/addon.xml
/Applications/Kodi.frappliance/AppData/AppHome/addons/pvr.mythtv/addon.xml
/Applications/Kodi.frappliance/AppData/AppHome/addons/pvr.nextpvr/addon.xml
/Applications/Kodi.frappliance/AppData/AppHome/addons/pvr.njoy/addon.xml
/Applications/Kodi.frappliance/AppData/AppHome/addons/pvr.vdr.vnsi/addon.xml
/Applications/Kodi.frappliance/AppData/AppHome/addons/pvr.vuplus/addon.xml
/Applications/Kodi.frappliance/AppData/AppHome/addons/pvr.wmc/addon.xml
/Applications/Kodi.frappliance/AppData/AppHome/addons/repository.xbmc.org/addon.xml
/Applications/Kodi.frappliance/AppData/AppHome/addons/screensaver.xbmc.builtin.black/addon.xml
/Applications/Kodi.frappliance/AppData/AppHome/addons/screensaver.xbmc.builtin.dim/addon.xml
/Applications/Kodi.frappliance/AppData/AppHome/addons/script.module.pil/addon.xml
/Applications/Kodi.frappliance/AppData/AppHome/addons/service.xbmc.versioncheck/addon.xml
/Applications/Kodi.frappliance/AppData/AppHome/addons/skin.confluence/addon.xml
/Applications/Kodi.frappliance/AppData/AppHome/addons/skin.re-touched/addon.xml
/Applications/Kodi.frappliance/AppData/AppHome/addons/visualization.glspectrum/addon.xml
/Applications/Kodi.frappliance/AppData/AppHome/addons/visualization.waveform/addon.xml
/Applications/Kodi.frappliance/AppData/AppHome/addons/webinterface.default/addon.xml
/Applications/Kodi.frappliance/AppData/AppHome/addons/xbmc.addon/addon.xml
/Applications/Kodi.frappliance/AppData/AppHome/addons/xbmc.codec/addon.xml
/Applications/Kodi.frappliance/AppData/AppHome/addons/xbmc.core/addon.xml
/Applications/Kodi.frappliance/AppData/AppHome/addons/xbmc.gui/addon.xml
/Applications/Kodi.frappliance/AppData/AppHome/addons/xbmc.json/addon.xml
/Applications/Kodi.frappliance/AppData/AppHome/addons/xbmc.metadata/addon.xml
/Applications/Kodi.frappliance/AppData/AppHome/addons/xbmc.pvr/addon.xml
/Applications/Kodi.frappliance/AppData/AppHome/addons/xbmc.python/addon.xml

/User/Library/Preferences/Kodi/addons/plugin.video.ipcams/addon.xml
/User/Library/Preferences/Kodi/addons/plugin.video.ted.talks/addon.xml
/User/Library/Preferences/Kodi/addons/script.hello.world/addon.xml
/User/Library/Preferences/Kodi/addons/script.module.elementtree/addon.xml
/User/Library/Preferences/Kodi/addons/script.module.parsedom/addon.xml

/private/var/mobile/Library/Preferences/Kodi/addons/plugin.video.ipcams/addon.xml
/private/var/mobile/Library/Preferences/Kodi/addons/plugin.video.ted.talks/addon.xml
/private/var/mobile/Library/Preferences/Kodi/addons/script.hello.world/addon.xml
/private/var/mobile/Library/Preferences/Kodi/addons/script.module.elementtree/addon.xml
/private/var/mobile/Library/Preferences/Kodi/addons/script.module.parsedom/addon.xml

/private/var/stash/Applications/Kodi.frappliance/AppData/AppHome/addons/audioencoder.flac/addon.xml
/private/var/stash/Applications/Kodi.frappliance/AppData/AppHome/addons/audioencoder.lame/addon.xml
/private/var/stash/Applications/Kodi.frappliance/AppData/AppHome/addons/audioencoder.vorbis/addon.xml
/private/var/stash/Applications/Kodi.frappliance/AppData/AppHome/addons/audioencoder.wav/addon.xml
/private/var/stash/Applications/Kodi.frappliance/AppData/AppHome/addons/audioencoder.xbmc.builtin.aac/addon.xml
/private/var/stash/Applications/Kodi.frappliance/AppData/AppHome/addons/audioencoder.xbmc.builtin.wma/addon.xml
/private/var/stash/Applications/Kodi.frappliance/AppData/AppHome/addons/metadata.album.universal/addon.xml
/private/var/stash/Applications/Kodi.frappliance/AppData/AppHome/addons/metadata.artists.universal/addon.xml
/private/var/stash/Applications/Kodi.frappliance/AppData/AppHome/addons/metadata.common.allmusic.com/addon.xml
/private/var/stash/Applications/Kodi.frappliance/AppData/AppHome/addons/metadata.common.amazon.de/addon.xml
/private/var/stash/Applications/Kodi.frappliance/AppData/AppHome/addons/metadata.common.fanart.tv/addon.xml
/private/var/stash/Applications/Kodi.frappliance/AppData/AppHome/addons/metadata.common.hdtrailers.net/addon.xml
/private/var/stash/Applications/Kodi.frappliance/AppData/AppHome/addons/metadata.common.htbackdrops.com/addon.xml
/private/var/stash/Applications/Kodi.frappliance/AppData/AppHome/addons/metadata.common.imdb.com/addon.xml
/private/var/stash/Applications/Kodi.frappliance/AppData/AppHome/addons/metadata.common.last.fm/addon.xml
/private/var/stash/Applications/Kodi.frappliance/AppData/AppHome/addons/metadata.common.musicbrainz.org/addon.xml
/private/var/stash/Applications/Kodi.frappliance/AppData/AppHome/addons/metadata.common.theaudiodb.com/addon.xml
/private/var/stash/Applications/Kodi.frappliance/AppData/AppHome/addons/metadata.common.themoviedb.org/addon.xml
/private/var/stash/Applications/Kodi.frappliance/AppData/AppHome/addons/metadata.local/addon.xml
/private/var/stash/Applications/Kodi.frappliance/AppData/AppHome/addons/metadata.musicvideos.theaudiodb.com/addon.xml
/private/var/stash/Applications/Kodi.frappliance/AppData/AppHome/addons/metadata.themoviedb.org/addon.xml
/private/var/stash/Applications/Kodi.frappliance/AppData/AppHome/addons/metadata.tvdb.com/addon.xml
/private/var/stash/Applications/Kodi.frappliance/AppData/AppHome/addons/pvr.argustv/addon.xml
/private/var/stash/Applications/Kodi.frappliance/AppData/AppHome/addons/pvr.demo/addon.xml
/private/var/stash/Applications/Kodi.frappliance/AppData/AppHome/addons/pvr.dvblink/addon.xml
/private/var/stash/Applications/Kodi.frappliance/AppData/AppHome/addons/pvr.dvbviewer/addon.xml
/private/var/stash/Applications/Kodi.frappliance/AppData/AppHome/addons/pvr.filmon/addon.xml
/private/var/stash/Applications/Kodi.frappliance/AppData/AppHome/addons/pvr.hts/addon.xml
/private/var/stash/Applications/Kodi.frappliance/AppData/AppHome/addons/pvr.iptvsimple/addon.xml
/private/var/stash/Applications/Kodi.frappliance/AppData/AppHome/addons/pvr.mediaportal.tvserver/addon.xml
/private/var/stash/Applications/Kodi.frappliance/AppData/AppHome/addons/pvr.mythtv/addon.xml
/private/var/stash/Applications/Kodi.frappliance/AppData/AppHome/addons/pvr.nextpvr/addon.xml
/private/var/stash/Applications/Kodi.frappliance/AppData/AppHome/addons/pvr.njoy/addon.xml
/private/var/stash/Applications/Kodi.frappliance/AppData/AppHome/addons/pvr.vdr.vnsi/addon.xml
/private/var/stash/Applications/Kodi.frappliance/AppData/AppHome/addons/pvr.vuplus/addon.xml
/private/var/stash/Applications/Kodi.frappliance/AppData/AppHome/addons/pvr.wmc/addon.xml
/private/var/stash/Applications/Kodi.frappliance/AppData/AppHome/addons/repository.xbmc.org/addon.xml
/private/var/stash/Applications/Kodi.frappliance/AppData/AppHome/addons/screensaver.xbmc.builtin.black/addon.xml
/private/var/stash/Applications/Kodi.frappliance/AppData/AppHome/addons/screensaver.xbmc.builtin.dim/addon.xml
/private/var/stash/Applications/Kodi.frappliance/AppData/AppHome/addons/script.module.pil/addon.xml
/private/var/stash/Applications/Kodi.frappliance/AppData/AppHome/addons/service.xbmc.versioncheck/addon.xml
/private/var/stash/Applications/Kodi.frappliance/AppData/AppHome/addons/skin.confluence/addon.xml
/private/var/stash/Applications/Kodi.frappliance/AppData/AppHome/addons/skin.re-touched/addon.xml
/private/var/stash/Applications/Kodi.frappliance/AppData/AppHome/addons/visualization.glspectrum/addon.xml
/private/var/stash/Applications/Kodi.frappliance/AppData/AppHome/addons/visualization.waveform/addon.xml
/private/var/stash/Applications/Kodi.frappliance/AppData/AppHome/addons/webinterface.default/addon.xml
/private/var/stash/Applications/Kodi.frappliance/AppData/AppHome/addons/xbmc.addon/addon.xml
/private/var/stash/Applications/Kodi.frappliance/AppData/AppHome/addons/xbmc.codec/addon.xml
/private/var/stash/Applications/Kodi.frappliance/AppData/AppHome/addons/xbmc.core/addon.xml
/private/var/stash/Applications/Kodi.frappliance/AppData/AppHome/addons/xbmc.gui/addon.xml
/private/var/stash/Applications/Kodi.frappliance/AppData/AppHome/addons/xbmc.json/addon.xml
/private/var/stash/Applications/Kodi.frappliance/AppData/AppHome/addons/xbmc.metadata/addon.xml
/private/var/stash/Applications/Kodi.frappliance/AppData/AppHome/addons/xbmc.pvr/addon.xml
/private/var/stash/Applications/Kodi.frappliance/AppData/AppHome/addons/xbmc.python/addon.xml
