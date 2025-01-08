@rem https://github.com/hankst69/UserScript-KnowHow
@rem https://github.com/hankst69/UserScripts
@echo off
call "%~dp0\maker_env.bat"

set "_USERSCRIPTS_DIR=%MAKER_PROJECTS%\Web\UserScripts"
set "_USERSCRIPTS_KNOWHOW_DIR=%MAKER_PROJECTS%\Web\KnowHow"

@call "%MAKER_SCRIPTS%\clone_in_folder.bat" "%_USERSCRIPTS_KNOWHOW_DIR%" "https://github.com/hankst69/UserScript-KnowHow"
@call "%MAKER_SCRIPTS%\clone_in_folder.bat" "%_USERSCRIPTS_DIR%" "https://github.com/hankst69/UserScripts" --changeDir --switchBranch DLWSMEDIA_with_HLSPlayer
