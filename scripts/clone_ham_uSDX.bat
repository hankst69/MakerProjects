@rem https://github.com/hankst69/uSDXOpen.git
@echo off
call "%~dp0\maker_env.bat"

set "MAKER_DIR_PROJECTS_HAM_USDX=%MAKER_DIR_PROJECTS%\uSDXOpen"

call "%MAKER_ENV_CORE%\clone_in_folder.bat" "%MAKER_DIR_PROJECTS_HAM_USDX%" "https://github.com/hankst69/uSDXOpen.git"

cd /d "%MAKER_DIR_PROJECTS_HAM_USDX%"