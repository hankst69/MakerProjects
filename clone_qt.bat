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
call "%~dp0\maker_env.bat"

set "_QT_DIR=%MAKER_TOOLS%\Qt"

set _QT_VERSION=6.6.3
if "%~1" neq "" set "_QT_VERSION=%~1"
set "_QT_SOURCES_DIR=%_QT_DIR%\qt_sources_%_QT_VERSION%\"

rem --- cloning QT
:qt_clone
rem if not exist "%_QT_DIR%" mkdir "%_QT_DIR%"
if exist "%_QT_SOURCES_DIR%\qtbase\configure.bat" echo QT-CLONE %_QT_VERSION% already done &goto :qt_clone_done

rem --- ensure perl (is required for cloning the qt submodules)
call "%MAKER_SCRIPTS%\validate_perl.bat"
if %ERRORLEVEL% NEQ 0 goto :EOF
echo.

echo QT-CLONE %_QT_VERSION%
call "%MAKER_SCRIPTS%\clone_in_folder.bat" "%_QT_SOURCES_DIR%" "https://code.qt.io/qt/qt5.git" --switchBranch %_QT_VERSION%
pushd "%_QT_SOURCES_DIR%"
call git pull
if not exist "%_QT_SOURCES_DIR%\qtbase\configure.bat" call perl "%_QT_SOURCES_DIR%\init-repository"
rem "%_QT_SOURCES_DIR%\configure" -init-submodules
rem "%_QT_SOURCES_DIR%\configure" -init-submodules -submodules qtdeclarative
popd
echo QT-CLONE %_QT_VERSION% done
:qt_clone_done

if not exist "%_QT_SOURCES_DIR%\qtbase\configure.bat" echo error: QT-CLONE %_QT_VERSION% failed &set _QT_SOURCES_DIR=
if "%_QT_SOURCES_DIR%" neq "" cd /d "%_QT_SOURCES_DIR%"
