@rem https://doc.qt.io/qt-6/getting-sources-from-git.html
@rem https://doc.qt.io/qt-6/configure-options.html
@rem https://doc.qt.io/qt-6/build-sources.html
@rem https://doc.qt.io/qt-6/windows-building.html
@rem https://code.qt.io/cgit
@rem 
@rem to solve SSL certificate issue when cloning 
@rem - see: https://stackoverflow.com/questions/23885449/unable-to-resolve-unable-to-get-local-issuer-certificate-using-git-on-windows
@rem -  do: git config --global http.sslbackend schannel
@echo off
call "%~dp0\maker_env.bat" %*
call "%MAKER_SCRIPTS%\clear_temp_envs.bat" "_QTC_" 1>nul 2>nul

rem assign target version and folder from commandline args
set "_QTC_VERSION=%MAKER_ENV_VERSION%"
set "_QTC_SRC_NAME=%MAKER_ENV_UNKNOWN_ARG_1%"
set "_QTC_SILENT_CLONE_MODE=%MAKER_ENV_SILENT%"
set _QTC_CLEAN_BEFORE_CLONE=
set _QTC_INIT_SUBMODULES=
set _QTC_CLONE_SUBMODULES=
for %%i in (%MAKER_ENV_UNKNOWN_SWITCHES%) do @if /I "%%~i" equ "--clean_before_clone" set _QTC_CLEAN_BEFORE_CLONE=true
for %%i in (%MAKER_ENV_UNKNOWN_SWITCHES%) do @if /I "%%~i" equ "--init_submodules" set _QTC_INIT_SUBMODULES=true
for %%i in (%MAKER_ENV_UNKNOWN_SWITCHES%) do @if /I "%%~i" equ "--clone_submodules" set _QTC_CLONE_SUBMODULES=-true

rem apply defaults
if "%_QTC_VERSION%"  equ "" set _QTC_VERSION=6.6.3
if "%_QTC_SRC_NAME%" equ "" set _QTC_SRC_NAME=qt_sources
if "%_QTC_INIT_SUBMODULES%" equ "" set _QTC_INIT_SUBMODULES=true
rem if "%_QTC_CLONE_SUBMODULES%" equ "" set _QTC_CLONE_SUBMODULES=true

rem define folders
set "_QTC_DIR=%MAKER_TOOLS%\Qt"
set "_QTC_SOURCES_DIR=%_QTC_DIR%\%_QTC_SRC_NAME%%_QTC_VERSION%\"

if "%MAKER_ENV_VERBOSE%" neq "" set _QTC_

if "%_QTC_CLEAN_BEFORE_CLONE%" neq "" (
  cd /d "%MAKER_ROOT%"
  echo preparing fresh clone by cleaning target folder
  rmdir /s /q "%_QTC_SOURCES_DIR%" 1>nul 2>nul
)
if exist "%_QTC_SOURCES_DIR%\qtbase\configure.bat" echo QT-CLONE %_QTC_VERSION% already done &goto :qt_clone_done


:qt_clone
if not exist "%_QTC_DIR%" mkdir "%_QTC_DIR%"
if not exist "%_QTC_SOURCES_DIR%" mkdir "%_QTC_SOURCES_DIR%"

rem ensure perl (is required for cloning the qt submodules)
call "%MAKER_BUILD%\validate_perl.bat"
if %ERRORLEVEL% NEQ 0 goto :EOF
echo.


echo QT-CLONE %_QTC_VERSION%
rem 1) clone repository
call "%MAKER_SCRIPTS%\clone_in_folder.bat" "%_QTC_SOURCES_DIR%" "https://code.qt.io/qt/qt5.git" --switchBranch %_QTC_VERSION% %_QTC_SILENT_CLONE_MODE%
pushd "%_QTC_SOURCES_DIR%"
rem 2) configure the repository
call git pull
if not exist "%_QTC_SOURCES_DIR%\qtbase\configure.bat" if exist "%_QTC_SOURCES_DIR%\init-repository.bat" call "%_QTC_SOURCES_DIR%\init-repository.bat"
if not exist "%_QTC_SOURCES_DIR%\qtbase\configure.bat" if not exist "%_QTC_SOURCES_DIR%\init-repository.bat" call perl "%_QTC_SOURCES_DIR%\init-repository"
rem 3) init submodules
if "%_QTC_INIT_SUBMODULES%" neq "" call git submodule init
rem 4) clone submodules
if "%_QTC_CLONE_SUBMODULES%" neq "" call git submodule update --init --recursive
popd
echo QT-CLONE %_QTC_VERSION% done


:qt_clone_done
if "%_QTC_SOURCES_DIR%" neq "" cd /d "%_QTC_SOURCES_DIR%"
set "QT_DIR=%_QTC_DIR%"
set "QT_SOURCES_DIR=%_QTC_SOURCES_DIR%"
set "QT_VERSION=%_QTC_VERSION%"
call "%MAKER_SCRIPTS%\clear_temp_envs.bat" "_QTC_" 1>nul 2>nul
if not exist "%QT_SOURCES_DIR%\qtbase\configure.bat" echo error: QT-CLONE %QT_VERSION% failed &set QT_SOURCES_DIR= &exit /b 1
