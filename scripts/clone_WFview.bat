@echo off
call "%~dp0\maker_env.bat" %*
call "%MAKER_ENV_CORE%\set_version_env" "WFVIEW" "%MAKER_VERSION%"

set "WFVIEW_BASE_DIR=wfview"
set "WFVIEW_DIR=%MAKER_DIR_PROJECTS%\%WFVIEW_BASE_DIR%"
rem pushd "%MAKER_ENV_ROOT%\.."
rem set "WFVIEW_DIR=%cd%\%WFVIEW_BASE_DIR%"
rem popd
set "WFVIEW_SRC_DIR=%WFVIEW_DIR%\%WFVIEW_BASE_DIR%_source%WFVIEW_VERSION%"

if /i "%MAKER_UNKNOWN_SWITCH_1%" equ "--do_not_clone" goto :EOF

rem wfview repository
rem https://gitlab.com/eliggett/wfview.git
rem https://gitlab.com/hankst69/wfview-wasm.git
if not exist "%WFVIEW_DIR%" mkdir "%WFVIEW_DIR%"

set "WFVIEW_MAIN_BRANCH=master"
set "WFVIEW_CHECKOUT_BRANCH=cmake_wasm"
rem if "%WFVIEW_VERSION_MAJOR%.%VERSION_MINOR%" equ "2.20" set "WFVIEW_CHECKOUT_BRANCH=v2.20-dev"
if "%MAKER_MSG_VERBOSE%" neq "" set WFVIEW_

call "%MAKER_ENV_CORE%\clone_in_folder.bat" "%WFVIEW_SRC_DIR%" "https://gitlab.com/hankst69/wfview-wasm.git" --switchBranch %WFVIEW_CHECKOUT_BRANCH% %MAKER_MSG_SILENT%

rem call "%~dp0\clone_WFViewLibs.bat" %*
cd /d "%WFVIEW_SRC_DIR%"


:: Sync Fork (master branch) with Origin git repository
:: Step 1: Add the upstream repository as a remote
git remote add upstream https://gitlab.com/eliggett/wfview.git
:: Step 2: Fetch changes from the upstream repository
git fetch upstream
:: Step 3: Merge changes into your local branch (e.g., main)
git checkout %WFVIEW_MAIN_BRANCH%
git pull
git merge upstream/%WFVIEW_MAIN_BRANCH%
:: Step 4: Push the updated branch to your fork
git push origin %WFVIEW_MAIN_BRANCH%

git switch %WFVIEW_CHECKOUT_BRANCH%