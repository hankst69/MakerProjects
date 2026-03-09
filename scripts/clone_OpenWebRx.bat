@rem "https://github.com/ha7ilm/openwebrx"
@rem "https://github.com/jketterl/openwebrx.git"
@rem "https://github.com/luarvique/openwebrx.git"
@echo off
call "%~dp0\maker_env.bat"

rem OpenWebRX  https://www.openwebrx.de/
rem OpenWebRX+ https://fms.komkon.org/OWRX/

set "MAKER_PROJECTS_OPENWEBRX=%MAKER_PROJECTS%\OpenWebRx"
set "_OPENWEBRX_DIR=%MAKER_PROJECTS_OPENWEBRX%"
set "_OPENWEBRX_SRC_DIR=%MAKER_PROJECTS_OPENWEBRX%\openwebrx"
set "_OPENWEBRX+_SRC_DIR=%MAKER_PROJECTS_OPENWEBRX%\openwebrx+"


call "%MAKER_SCRIPTS%\clone_in_folder.bat" "%_OPENWEBRX_SRC_DIR%"  "https://github.com/jketterl/openwebrx.git" --switchBranch develop
call "%MAKER_SCRIPTS%\clone_in_folder.bat" "%_OPENWEBRX+_SRC_DIR%" "https://github.com/luarvique/openwebrx.git"

cd /d "%_OPENWEBRX_DIR%"
dir /ad