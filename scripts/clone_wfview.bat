@rem https://gitlab.com/eliggett/wfview.git
@echo off
call "%~dp0\maker_env.bat" %*

call "%MAKER_SCRIPTS%\set_version_env" "WFVIEW" "%MAKER_ENV_VERSION%"
set "WFVIEW_BASE_DIR=wfview"
set "WFVIEW_DIR=%MAKER_PROJECTS%\wfview"
set "WFVIEW_SCR_DIR=%WFVIEW_DIR%\%WFVIEW_BASE_DIR%_source%WFVIEW_VERSION%"

set "WFVIEW_SILENT_CLONE_MODE=%MAKER_ENV_SILENT%"
set "WFVIEW_CHECKOUT_BRANCH="
if "%WFVIEW_VERSION_MAJOR%.%VERSION_MINOR%" equ "2.20" set "WFVIEW_CHECKOUT_BRANCH=--switchBranch v2.20-dev"

if "%MAKER_ENV_VERBOSE%" neq "" set WFVIEW_

if not exist "%WFVIEW_DIR%" mkdir "%WFVIEW_DIR%"
cd /d "%WFVIEW_DIR%"
call "%MAKER_SCRIPTS%\clone_in_folder.bat" "%WFVIEW_SCR_DIR%" "https://gitlab.com/eliggett/wfview.git" %WFVIEW_CHECKOUT_BRANCH% %WFVIEW_SILENT_CLONE_MODE%
