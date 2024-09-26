@echo off
set "_MAKER_ROOT=%~dp0"
rem https://doc.qt.io/qt-6/getting-sources-from-git.html
rem https://doc.qt.io/qt-6/configure-options.html
rem https://doc.qt.io/qt-6/build-sources.html
rem https://doc.qt.io/qt-6/windows-building.html
rem https://code.qt.io/cgit

set _QT_VERSION=6.6.3
if "%~1" neq "" set "_QT_VERSION=%~1"

rem 1) cloning QT sources
rem defines: _QT_DIR
rem defines: _QT_SOURCES_DIR
call "%_MAKER_ROOT%\clone_qt.bat" %_QT_VERSION%
if "%_QT_DIR%" EQU "" (echo cloning Qt %_QT_VERSION% failed &goto :EOF)
if "%_QT_SOURCES_DIR%" EQU "" (echo cloning Qt %_QT_VERSION% failed &goto :EOF)
if not exist "%_QT_DIR%" (echo cloning Qt %_QT_VERSION% failed &goto :EOF)
if not exist "%_QT_SOURCES_DIR%" (echo cloning Qt %_QT_VERSION% failed &goto :EOF)

set "_QT_BUILD_DIR=%_QT_DIR%\qt_build_%_QT_VERSION%"
set "_QT_BIN_DIR=%_QT_DIR%\qt%_QT_VERSION%"

rem test msvs
rem ...tbd
:test_msvs_success
rem test cmake
call which cmake.exe 1>nul 2>nul
if %ERRORLEVEL% EQU 0 goto :test_cmake_success
echo error: cmake is not available
goto :EOF
:test_cmake_success
rem test ninja
rem ...tbd
:test_ninja_success
rem test llvm (set LLVM_INSTALL_DIR + need to set the FEATURE_clang and FEATURE_clangcpp CMake variable to ON to re-evaluate this checks)
rem ...tbd
:test_llvm_success
rem test perl (+ gperf + qnx)
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

rem 2) configure QT win build
:qt_configure
if exist "%_QT_BUILD_DIR%\qtbase\bin\qt-cmake.bat" echo QT-CONFIGURE already done &goto :qt_configure_done
rmdir /s /q "%_QT_BUILD_DIR%"
mkdir "%_QT_BUILD_DIR%"
pushd "%_QT_BUILD_DIR%"
call python -m pip install html5lib
rem call python -m pip wheel html5lib
call "%_QT_SOURCES_DIR%\configure.bat" -prefix "%_QT_BIN_DIR%" -release -force-debug-info -separate-debug-info >"%_QT_DIR%\qt_build_%_QT_VERSION%_configure.log"
popd
:qt_configure_done

rem 3) build QT
:qt_build
if exist "%_QT_BIN_DIR%\bin\designer.exe" echo QT-BUILD already done &goto :qt_build_done
pushd "%_QT_BUILD_DIR%"
call cmake --build . --parallel
popd
:qt_build_done

rem 4) install QT 
:qt_install
call which Qt6WebSockets.dll 1>nul 2>nul
if %ERRORLEVEL% EQU 0 echo QT-INSTALL already done&goto :qt_install_done
if not exist "%_QT_BIN_DIR%\bin\Qt6WebSockets.dll" (
  pushd "%_QT_BUILD_DIR%"
  call cmake --install .
  popd
  if not exist "%_QT_BIN_DIR%\bin\Qt6WebSockets.dll" echo error: QT-INSTALL FAILED&goto :qt_install_done
)
echo QT-INSTALL done
call which Qt6WebSockets.dll 1>nul 2>nul
if %ERRORLEVEL% EQU 0 goto :qt_install_done
set "PATH=%PATH%;%_QT_BIN_DIR%\bin"
:qt_install_done

rem 5) post configure QT
rem call "_QT_BIN_DIR%/bin/qt-configure-module.bat"

cd "%_QT_DIR%"
