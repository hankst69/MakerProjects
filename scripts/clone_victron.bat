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

if "%MAKER_ENV_VERSION%" neq "" (
  echo error: cloning of a dedicated version is currently not supported in script '%~nx0'
  rem echo        resetting MAKER_ENV_VERSION from: "%MAKER_ENV_VERSION%" to: ""
  goto :EOF
)
rem set MAKER_ENV_VERSION=

set "VICTRON_DIR=%MAKER_PROJECTS%\Victron"
set "VICTRON_GUIV2_VERSION=%MAKER_ENV_VERSION%"
set "VICTRON_GUIV2_BASE_DIR=%VICTRON_DIR%\venus-guiv2%VICTRON_GUIV2_VERSION%"
set "VICTRON_GUIV2_SRC_DIR=%VICTRON_GUIV2_BASE_DIR%_source"
set "VICTRON_HTMLAPP_DIR=%VICTRON_DIR%\venus-html5-app"

if "%MAKER_ENV_VERBOSE%" neq "" set VICTRON_

call "%MAKER_SCRIPTS%\clone_in_folder.bat" "%VICTRON_GUIV2_SRC_DIR%" "https://github.com/victronenergy/gui-v2.git" %*
rem we also have to clone the needed submodules (veutil and qzxing ..)
pushd "%VICTRON_GUIV2_SRC_DIR%"
call git submodule update --init
popd

call "%MAKER_SCRIPTS%\clone_in_folder.bat" "%VICTRON_HTMLAPP_DIR%" "https://github.com/victronenergy/venus-html5-app.git" %*

rem set "VICTRON_VENUSOS_SRC_DIR=%_VICTRON_DIR%\venus-os_source"
rem call "%MAKER_SCRIPTS%\clone_in_folder.bat" "%VICTRON_VENUSOS_DIR%" "https://github.com/victronenergy/venus.git" %*

cd /d "%VICTRON_DIR%"