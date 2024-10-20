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


rem echo test msvs
rem ...tbd
:test_msvs_success

rem echo test cmake
call which cmake.exe 1>nul 2>nul
if %ERRORLEVEL% EQU 0 goto :test_cmake_success
echo error: CMAKE is not available
goto :EOF
:test_cmake_success
set _VERSION_NR=
for /f "tokens=1-3 delims= " %%i in ('call cmake --version') do if /I "%%j" EQU "version" set "_VERSION_NR=%%k"
echo using: cmake %_VERSION_NR%
set _VERSION_NR=

rem echo test ninja
call which ninja.exe 1>nul 2>nul
if %ERRORLEVEL% EQU 0 goto :test_ninja_success
echo warning: NINJA is not available
rem goto :EOF
:test_ninja_success
set _VERSION_NR=
for /f "tokens=1,* delims= " %%i in ('call ninja --version') do set "_VERSION_NR=%%i"
echo using: ninja %_VERSION_NR%
set _VERSION_NR=

rem echo test llvm (set LLVM_INSTALL_DIR + need to set the FEATURE_clang and FEATURE_clangcpp CMake variable to ON to re-evaluate this checks)
rem ...tbd
:test_llvm_success

rem echo test perl (+ gperf + qnx)
call which perl.exe 1>nul 2>nul
if %ERRORLEVEL% EQU 0 goto :test_perl_success
echo error: perl is not available
goto :EOF
:test_perl_success
set _VERSION_NR=
for /f "tokens=1,2 delims=^(" %%i in ('call perl --version') do for /f "tokens=1,* delims=)" %%k in ("%%j") do set "_VERSION_NR=%%k"
echo using: perl %_VERSION_NR%
set _VERSION_NR=

rem echo test python
call which python.exe 1>nul 2>nul
if %ERRORLEVEL% EQU 0 goto :test_python_success
echo error: python is not available
goto :EOF
:test_python_success
set _VERSION_NR=
for /f "tokens=1,2 delims= " %%i in ('call python --version') do set "_VERSION_NR=%%j"
echo using: python %_VERSION_NR%
set _VERSION_NR=


rem 2) configure QT build
:qt_configure
if exist "%_QT_BUILD_DIR%\qtbase\bin\qt-cmake.bat" echo QT-CONFIGURE %_QT_VERSION% already done &goto :qt_configure_done
echo QT-CONFIGURE %_QT_VERSION%
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
if exist "%_QT_BIN_DIR%\bin\designer.exe" echo QT-BUILD %_QT_VERSION% already done &goto :qt_build_done
echo QT-BUILD %_QT_VERSION%
pushd "%_QT_BUILD_DIR%"
call cmake --build . --parallel
popd
:qt_build_done


rem 4) install QT 
:qt_install
if not exist "%_QT_BIN_DIR%\bin\Qt6WebSockets.dll" (
  echo QT-INSTALL %_QT_VERSION%
  pushd "%_QT_BUILD_DIR%"
  call cmake --install .
  popd
  if not exist "%_QT_BIN_DIR%\bin\Qt6WebSockets.dll" echo error: QT-INSTALL %_QT_VERSION% FAILED&goto :qt_install_done
  call which Qt6WebSockets.dll 1>nul 2>nul
  if %ERRORLEVEL% NEQ 0 set "PATH=%PATH%;%_QT_BIN_DIR%\bin"
  echo QT-INSTALL %_QT_VERSION% done
) else (
  call which Qt6WebSockets.dll 1>nul 2>nul
  if %ERRORLEVEL% EQU 0 echo QT-INSTALL %_QT_VERSION% already done&goto :qt_install_done
)
:qt_install_done


rem 5) post configure QT
rem call "_QT_BIN_DIR%/bin/qt-configure-module.bat"

cd "%_QT_DIR%"
