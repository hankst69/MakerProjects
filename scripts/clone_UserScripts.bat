@rem https://github.com/hankst69/UserScript-KnowHow
@rem https://github.com/hankst69/UserScripts
@rem https://github.com/gildas-lormeau/SingleFile-MV3
@echo off
call "%~dp0\maker_env.bat"

set "_USERSCRIPTS_DIR=%MAKER_PROJECTS_WEB%\UserScripts"
set "_USERSCRIPTS_KNOWHOW_DIR=%MAKER_PROJECTS_WEB%\KnowHow"

@call "%MAKER_SCRIPTS%\clone_in_folder.bat" "%_USERSCRIPTS_KNOWHOW_DIR%" "https://github.com/hankst69/UserScript-KnowHow"
@call "%MAKER_SCRIPTS%\clone_in_folder.bat" "%_USERSCRIPTS_DIR%" "https://github.com/hankst69/UserScripts" --changeDir --switchBranch DLWSMEDIA_with_HLSPlayer
@call "%MAKER_SCRIPTS%\clone_in_folder.bat" "%_USERSCRIPTS_DIR%\SingleFile-MV3" "https://github.com/gildas-lormeau/SingleFile-MV3"
