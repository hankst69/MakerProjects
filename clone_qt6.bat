@echo off
rem https://doc.qt.io/qt-6/getting-sources-from-git.html
rem https://doc.qt.io/qt-6/configure-options.html
rem https://doc.qt.io/qt-6/build-sources.html
rem https://doc.qt.io/qt-6/windows-building.html
rem https://code.qt.io/cgit

set "_QT_DIR=%~dp0qt6"
set "_QT_VERSION=6.6.3"
if "%~1" neq "" set "_QT_VERSION=%~1"

set "_QT_SOURCES_DIR=%_QT_DIR%\qt_sources\"
set "_QT_BUILD_DIR=%_QT_DIR%\qt_build"
set "_QT_BIN_DIR=%_QT_DIR%\bin"

rem test msvs
:test_msvs_success
rem test cmake
call which cmake.exe 1>nul 2>nul
if %ERRORLEVEL% EQU 0 goto :test_cmake_success
echo error: cmake is not available
goto :EOF
:test_cmake_success
rem test ninja
:test_ninja_success
rem test llvm
:test_llvm_success
rem test perl
call which perl.exe 1>nul 2>nul
if %ERRORLEVEL% EQU 0 goto :test_perl_success
echo error: perl is not available
goto :EOF
:test_perl_success
rem test python
call which python.exe 1>nul 2>nul
if %ERRORLEVEL% EQU 0 goto :test_python_success
echo error: python is not available
goto :EOF
:test_python_success

rem 1) preparations
if not exist "%_QT_DIR%" mkdir "%_QT_DIR%"
call python -m pip install html5lib
rem call python -m pip wheel html5lib

rem 2) cloning QT
:qt_clone
pushd "%_QT_DIR%"
call "%~dp0scripts\clone_in_folder.bat" "%_QT_SOURCES_DIR%" "https://code.qt.io/qt/qt5.git" --switchBranch %_QT_VERSION%
call git pull
if not exist "%_QT_SOURCES_DIR%\qtbase\configure.bat" call perl init-repository
rem "%_QT_SOURCES_DIR%\configure" -init-submodules
rem "%_QT_SOURCES_DIR%\configure" -init-submodules -submodules qtdeclarative
popd
:qt_clone_done

rem 3) configure QT
:qt_configure
if exist "%_QT_BUILD_DIR%\qtbase\bin\qt-cmake.bat" echo QT-CONFIGURE already done &goto :qt_configure_done
rmdir /s /q "%_QT_BUILD_DIR%"
mkdir "%_QT_BUILD_DIR%"
pushd "%_QT_BUILD_DIR%"
call "%_QT_SOURCES_DIR%\configure.bat" -prefix "%_QT_BIN_DIR%" -release -force-debug-info -separate-debug-info >"%_QT_DIR%\qt-build-configure.log"
popd
:qt_configure_done

rem 4) build QT
:qt_build
if exist "%QT_BIN_DIR%\bin\designer.exe" echo QT-BUILD already done &goto :qt_build_done
pushd "%_QT_BUILD_DIR%"
call cmake --build . --parallel
popd
:qt_build_done

rem 5) install QT 
:qt_install
if exist "%QT_BIN_DIR%\bin\designer.exe" echo QT-INSTALL already done &goto :qt_install_done
pushd "%_QT_BUILD_DIR%"
call cmake --install .
popd
:qt_install_done

rem 6) post configure QT
rem call "_QT_BIN_DIR%/bin/qt-configure-module.bat"

