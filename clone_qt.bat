@echo off
rem https://doc.qt.io/qt-6/getting-sources-from-git.html
rem https://doc.qt.io/qt-6/configure-options.html
rem https://doc.qt.io/qt-6/build-sources.html
rem https://doc.qt.io/qt-6/windows-building.html
rem https://code.qt.io/cgit

set "_QT_DIR=%~dp0Qt"
if not exist "%_QT_DIR%" mkdir "%_QT_DIR%"

set _QT_VERSION=6.6.3
if "%~1" neq "" set "_QT_VERSION=%~1"

rem test perl (+ gperf + qnx)
call which perl.exe 1>nul 2>nul
if %ERRORLEVEL% EQU 0 goto :test_perl_success
echo error: perl is not available
goto :EOF
:test_perl_success

set "_QT_SOURCES_DIR=%_QT_DIR%\qt_sources_%_QT_VERSION%\"

rem cloning QT
:qt_clone
if exist "%_QT_SOURCES_DIR%\qtbase\configure.bat" echo QT-CLONE already done &goto :qt_clone_done
call "%~dp0scripts\clone_in_folder.bat" "%_QT_SOURCES_DIR%" "https://code.qt.io/qt/qt5.git" --switchBranch %_QT_VERSION%
pushd "%_QT_SOURCES_DIR%"
call git pull
if not exist "%_QT_SOURCES_DIR%\qtbase\configure.bat" call perl "%_QT_SOURCES_DIR%\init-repository"
rem "%_QT_SOURCES_DIR%\configure" -init-submodules
rem "%_QT_SOURCES_DIR%\configure" -init-submodules -submodules qtdeclarative
popd
:qt_clone_done

if not exist "%_QT_SOURCES_DIR%\qtbase\configure.bat" echo error: cloning failed &set _QT_SOURCES_DIR=
if "%_QT_SOURCES_DIR%" neq "" cd /d "%_QT_SOURCES_DIR%"
