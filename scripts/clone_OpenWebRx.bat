@rem "https://github.com/jketterl/openwebrx.git"
@echo off
call "%~dp0\maker_env.bat"

set "MAKER_PROJECTS_OPENWEBRX=%MAKER_PROJECTS%\OpenWebRx"
set "_OPENWEBRX_DIR=%MAKER_PROJECTS_OPENWEBRX%"

call "%MAKER_SCRIPTS%\clone_in_folder.bat" "%_OPENWEBRX_DIR%" "https://github.com/jketterl/openwebrx.git" --changeDir --switchBranch develop
rem call "%MAKER_SCRIPTS%\clone_in_folder.bat" "%_OPENWEBRX_DIR%" "https://github.com/jketterl/openwebrx.git" --changeDir --switchBranch sstv
