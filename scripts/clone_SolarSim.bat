@rem https://github.com/hankst69/SolarSim.git
@echo off
call "%~dp0\maker_env.bat"

set "MAKER_DIR_PROJECTS_SOLARSIM=%MAKER_DIR_PROJECTS%\SolarSim"

call "%MAKER_ENV_CORE%\clone_in_folder.bat" "%MAKER_DIR_PROJECTS_SOLARSIM%" "https://github.com/hankst69/SolarSim.git" --changeDir
