@rem https://github.com/victronenergy/gui-v2.git
@rem https://github.com/victronenergy/venus-html5-app.git
@rem https://github.com/victronenergy/venus.git
@echo off
call "%~dp0\maker_env.bat" %*

set VICTRON_DIR=
set VICTRON_GUIV2_VERSION=
set VICTRON_GUIV2_BASE_DIR=
set VICTRON_GUIV2_SRC_DIR=
set VICTRON_HTMLAPP_DIR=

rem if "%MAKER_ENV_VERSION%" neq "" (
rem   echo error: cloning of a dedicated version is currently not supported in script '%~nx0'
rem   goto :EOF
rem )

set "VICTRON_DIR=%MAKER_PROJECTS%\Victron"
set "VICTRON_GUIV2_VERSION=%MAKER_ENV_VERSION%"
set "VICTRON_GUIV2_BASE_DIR=%VICTRON_DIR%\venus-guiv2"
set "VICTRON_GUIV2_SRC_DIR=%VICTRON_GUIV2_BASE_DIR%_source%VICTRON_GUIV2_VERSION%"
set "VICTRON_HTMLAPP_DIR=%VICTRON_DIR%\venus-html5-app"
set "VICTRON_SILENT_CLONE_MODE=%MAKER_ENV_SILENT%"
set "VICTRON_CHECKOUT_TAG=--checkoutTag %VICTRON_GUIV2_VERSION%"
if "%VICTRON_GUIV2_VERSION%" equ "" set VICTRON_CHECKOUT_TAG=

if "%MAKER_ENV_VERBOSE%" neq "" set VICTRON_

call "%MAKER_SCRIPTS%\clone_in_folder.bat" "%VICTRON_GUIV2_SRC_DIR%" "https://github.com/victronenergy/gui-v2.git" %VICTRON_CHECKOUT_TAG% %VICTRON_SILENT_CLONE_MODE%
rem we also have to clone the needed submodules (veutil and qzxing ..)
pushd "%VICTRON_GUIV2_SRC_DIR%"
call git submodule update --init
popd

call "%MAKER_SCRIPTS%\clone_in_folder.bat" "%VICTRON_HTMLAPP_DIR%" "https://github.com/victronenergy/venus-html5-app.git" %*

rem set "VICTRON_VENUSOS_SRC_DIR=%_VICTRON_DIR%\venus-os_source"
rem call "%MAKER_SCRIPTS%\clone_in_folder.bat" "%VICTRON_VENUSOS_DIR%" "https://github.com/victronenergy/venus.git" %*

cd /d "%VICTRON_DIR%"