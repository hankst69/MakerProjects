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
if /I "%~1" equ "-?" goto :_QTC_USAGE
if /I "%~1" equ "-h" goto :_QTC_USAGE
if /I "%~1" equ "--help" goto :_QTC_USAGE
goto :_QTC_START

:_QTC_USAGE
echo USAGE:
echo %~n0 [version] [clone-dir-suffix]  [--clone_submodules] [--dont_init_submodules] [--force_clone] [--clean_before_clone] [--clone_webengine]
echo.%~n0 [--help^|-h^|-?]
goto :EOF

:_QTC_START
call "%~dp0\maker_env.bat" %*
call "%MAKER_ENV_CORE%\clear_temp_envs.bat" "_QTC_" 1>nul 2>nul
set "_QTC_START_DIR=%cd%"

rem assign target version and folder from commandline args
set "_QTC_VERSION=%MAKER_VERSION%"
set "_QTC_SRC_DIR_NAME_SUFFIX=%MAKER_UNKNOWN_ARG_1%"
set "_QTC_SILENT_CLONE_MODE=%MAKER_MSG_SILENT%"
set _QTC_FORCE_CLONE=
set _QTC_CLEAN_BEFORE_CLONE=
set _QTC_INIT_SUBMODULES=true
set _QTC_CLONE_SUBMODULES=
set _QTC_INITREPOSITORY_ARGS=--module-subset=default,-qtwebengine
set _QTC_USAGE=
for %%i in (%MAKER_UNKNOWN_SWITCHES%) do @if /I "%%~i" equ "--force_clone"          set _QTC_FORCE_CLONE=true
for %%i in (%MAKER_UNKNOWN_SWITCHES%) do @if /I "%%~i" equ "--clean_before_clone"   set _QTC_CLEAN_BEFORE_CLONE=true
for %%i in (%MAKER_UNKNOWN_SWITCHES%) do @if /I "%%~i" equ "--init_submodules"      set _QTC_INIT_SUBMODULES=true
for %%i in (%MAKER_UNKNOWN_SWITCHES%) do @if /I "%%~i" equ "--dont_init_submodules" set _QTC_INIT_SUBMODULES=
for %%i in (%MAKER_UNKNOWN_SWITCHES%) do @if /I "%%~i" equ "--clone_submodules"     set _QTC_CLONE_SUBMODULES=true
for %%i in (%MAKER_UNKNOWN_SWITCHES%) do @if /I "%%~i" equ "--clone_webengine"      set _QTC_INITREPOSITORY_ARGS=


rem apply defaults
if "%_QTC_VERSION%"  equ "" set _QTC_VERSION=6.8.3
set "_QTC_VERSION_COMPACT=%_QTC_VERSION:.=%"
set "_QTC_SRC_DIR_NAME=qt%_QTC_VERSION_COMPACT%src"
if "%_QTC_SRC_DIR_NAME_SUFFIX%" neq "" set "_QTC_SRC_DIR_NAME=qt%_QTC_VERSION_COMPACT%-%_QTC_SRC_DIR_NAME_SUFFIX%"


rem define folders
rem set "_QTC_DIR=%MAKER_DIR_TOOLS%\QT"
set "_QTC_DIR=%MAKER_DIR_QT%"
set "_QTC_SOURCES_DIR=%_QTC_DIR%\%_QTC_SRC_DIR_NAME%\"

if "%MAKER_MSG_VERBOSE%" neq "" set _QTC_

if "%_QTC_CLEAN_BEFORE_CLONE%" neq "" (
  cd /d "%MAKER_ENV_ROOT%"
  echo preparing fresh clone by cleaning target folder
  rmdir /s /q "%_QTC_SOURCES_DIR%" 1>nul 2>nul
)
if "%_QTC_FORCE_CLONE%%_QTC_CLONE_SUBMODULES%" neq "" (
  if exist "%_QTC_SOURCES_DIR%\qtbase\*" (
    rem if "%_QTC_FORCE_CLONE%" neq "" 
    (
      del /F /Q "%_QTC_SOURCES_DIR%\qtbase\configure.bat" 1>nul 2>nul
      rmdir /s /q "%_QTC_SOURCES_DIR%\qtbase"
    )
    if not exist "%_QTC_SOURCES_DIR%\qtbase\*" mkdir "%_QTC_SOURCES_DIR%\qtbase"
    pushd "%_QTC_SOURCES_DIR%\qtbase"
    call git restore qtbase 1>nul 2>nul
    popd
  )
)

if "%_QTC_FORCE_CLONE%%_QTC_CLONE_SUBMODULES%" equ "" (
  if exist "%_QTC_SOURCES_DIR%\qtbase\configure.bat" (
    echo QT-CLONE %_QTC_VERSION% %_QTC_SRC_DIR_NAME_SUFFIX% already done
    goto :qt_clone_done
  )
)


:qt_clone
if not exist "%_QTC_DIR%" mkdir "%_QTC_DIR%"
if not exist "%_QTC_SOURCES_DIR%" mkdir "%_QTC_SOURCES_DIR%"
rem echo.
echo QT-CLONE %_QTC_VERSION% %_QTC_SRC_DIR_NAME_SUFFIX%
rem 1) clone repository
call "%MAKER_ENV_CORE%\clone_in_folder.bat" "%_QTC_SOURCES_DIR%" "https://code.qt.io/qt/qt5.git" --switchBranch %_QTC_VERSION% %_QTC_SILENT_CLONE_MODE%
pushd "%_QTC_SOURCES_DIR%"
call git pull
popd

:qt_init_submodules_prepare
if not exist "%_QTC_SOURCES_DIR%\qtbase\configure.bat" (
  del /F /Q "%_QTC_SOURCES_DIR%\.qt_init_submodules_done" 1>nul 2>nul
  pushd "%_QTC_SOURCES_DIR%\qtbase"
  call git pull
  popd
)

:qt_init_submodules
if "%_QTC_INIT_SUBMODULES%" equ "" goto :qt_clone_done
if exist "%_QTC_SOURCES_DIR%\.qt_init_submodules_done" goto :qt_clone_done
:: ensure perl (is required for cloning the qt submodules)
call "%MAKER_DIR_SCRIPTS%\validate_perl.bat" --no_infos
if %ERRORLEVEL% NEQ 0 goto :qt_clone_failed
pushd "%_QTC_SOURCES_DIR%"
:: init the repositories submodules
if exist "%_QTC_SOURCES_DIR%\init-repository.bat"     call "%_QTC_SOURCES_DIR%\init-repository.bat" %_QTC_INITREPOSITORY_ARGS%  --force  || goto :qt_clone_failed
if not exist "%_QTC_SOURCES_DIR%\init-repository.bat" call perl "%_QTC_SOURCES_DIR%\init-repository" %_QTC_INITREPOSITORY_ARGS%  --force || goto :qt_clone_failed
:: init via git instead of qt-script init-repository
rem call git submodule init || goto :qt_clone_failed
rem call git submodule update --init --recursive || goto :qt_clone_failed
echo qt_init_submodules_done>.qt_init_submodules_done
popd
goto :qt_clone_done


:qt_clone_done
if not exist "%_QTC_SOURCES_DIR%\.qt_init_submodules_done" goto :qt_clone_failed
echo QT-CLONE %_QTC_VERSION% %_QTC_SRC_DIR_NAME_SUFFIX% done
if "%_QTC_SOURCES_DIR%" neq "" cd /d "%_QTC_SOURCES_DIR%"
set "QT_DIR=%_QTC_DIR%"
set "QT_SOURCES_DIR=%_QTC_SOURCES_DIR%"
set "QT_VERSION=%_QTC_VERSION%"
call "%MAKER_ENV_CORE%\clear_temp_envs.bat" "_QTC_" 1>nul 2>nul
goto :EOF


:qt_clone_failed
echo error: QT-CLONE %QT_VERSION% %_QTC_SRC_DIR_NAME_SUFFIX% failed
set QT_DIR=
set QT_SOURCES_DIR=
set QT_VERSION=
cd /d "%_QTC_START_DIR%"
call "%MAKER_ENV_CORE%\clear_temp_envs.bat" "_QTC_" 1>nul 2>nul
exit /b 1
