@echo off
call "%~dp0\maker_env.bat" %*
call "%MAKER_SCRIPTS%\set_version_env" "WFVIEW" "%MAKER_ENV_VERSION%"

set "WFVIEW_BASE_DIR=wfview"
set "WFVIEW_DIR=%MAKER_PROJECTS%\%WFVIEW_BASE_DIR%"
set "WFVIEW_SRC_DIR=%WFVIEW_DIR%\%WFVIEW_BASE_DIR%_source%WFVIEW_VERSION%"

if /i "%MAKER_ENV_UNKNOWN_SWITCH_1%" equ "--do_not_clone" goto :EOF

rem wfview repository
rem https://gitlab.com/eliggett/wfview.git
rem https://gitlab.com/hankst69/wfview.git
if not exist "%WFVIEW_DIR%" mkdir "%WFVIEW_DIR%"

set WFVIEW_CHECKOUT_BRANCH=
if "%WFVIEW_VERSION_MAJOR%.%VERSION_MINOR%" equ "2.20" set "WFVIEW_CHECKOUT_BRANCH=--switchBranch v2.20-dev"
if "%MAKER_ENV_VERBOSE%" neq "" set WFVIEW_

call "%MAKER_SCRIPTS%\clone_in_folder.bat" "%WFVIEW_SRC_DIR%" "https://gitlab.com/hankst69/wfview.git" %WFVIEW_CHECKOUT_BRANCH% %MAKER_ENV_SILENT%

call "%~dp0\clone_WFViewLibs.bat" %*
cd /d "%WFVIEW_SRC_DIR%"
