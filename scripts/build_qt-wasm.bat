@rem https://doc.qt.io/qt-6/wasm.html
@echo off
call "%~dp0\maker_env.bat" %*

call "%MAKER_SCRIPTS%\clear_temp_envs.bat" "_QTW_" 1>nul 2>nul
set "_QTW_START_DIR=%cd%"

if "%MAKER_ENV_VERBOSE%" neq "" echo on

set "_QTW_VERSION=%MAKER_ENV_VERSION%"
set "_QTW_REBUILD=%MAKER_ENV_REBUILD%"

rem apply defaults
if "%_QTW_VERSION%" equ "" set _QTW_VERSION=6.6.3

set "_QTW_CLONE_OPTIONS=--silent --init_submodules --clone_submodules"
if "%_QTW_REBUILD%" neq "" set "_QTW_CLONE_OPTIONS=--silent --clean_before_clone --init_submodules --clone_submodules"


rem (1) *** build QT ***
rem we need a QT Host version of same version as the target QT-QWASM we like to build
call "%MAKER_BUILD%\validate_qt.bat" %_QTW_VERSION% %MAKER_ENV_VERBOSE%
if %ERRORLEVEL% EQU 0 goto :qtw_continue
call "%MAKER_BUILD%\build_qt.bat" %_QTW_VERSION% %MAKER_ENV_VERBOSE%
call "%MAKER_BUILD%\validate_qt.bat" %_QTW_VERSION% %MAKER_ENV_VERBOSE%
if %ERRORLEVEL% NEQ 0 (
  echo building Qt %_QTW_VERSION% failed
  goto :qtw_exit
)
:qtw_continue
rem defines: QT_DIR
rem defines: QT_SOURCES_DIR
rem defines: QT_BIN_DIR
rem defines: QT_VERSION
rem defines: QT_CMAKE
rem defines: QT_LLVM_VER
if "%QT_BIN_DIR%" EQU "" (echo error: Qt %_QTW_VERSION% not available &goto :qtw_exit)
if not exist "%QT_BIN_DIR%" (echo error: Qt %_QTW_VERSION% not available &goto :qtw_exit)
if not exist "%QT_BIN_DIR%\lib\cmake\Qt6Mqtt\Qt6MqttConfig.cmake" (echo error: Qt %_QT_VERSION% incomplete &goto :qtw_exit)
if not exist "%QT_BIN_DIR%\bin\Qt6WebSockets.dll" (echo error: Qt %_QTW_VERSION% incomplete &goto :qtw_exit)


rem (2) *** clone qt again for wasm-build ***
call "%MAKER_BUILD%\clone_qt.bat" "%_QTW_VERSION%" "qt-wasm" %MAKER_ENV_VERBOSE% %_QTW_CLONE_OPTIONS%
rem defines: QT_DIR
rem defines: QT_SOURCES_DIR
rem clone_qt might switch folder so we switch back:
cd /d "%_QTW_START_DIR%"
rem with QT-WASM the Build-Dir is the Source_Dir
set "_QTW_BUILD_DIR=%QT_SOURCES_DIR%"


if "%MAKER_ENV_VERBOSE%" neq "" set _QTW_


rem (3) *** patch QT-WASM CMake files ***
rem
rem Note:
rem https://github.com/victronenergy/gui-v2/wiki/How-to-build-venus-gui-v2#building-for-webassembly
rem Building qt 6.6.1 for wasm_singlethread on Windows 10/11 seems to have a couple of quirks.
rem First, need to edit ~/Qt/6.6.1/wasm_singlethread/lib/cmake/Qt6BuildInternals/QtBuildInternalsExtra.cmake to ensure that the Qt paths are properly escaped (e.g. C:\\Development\\Qt\\6.6.1\\wasm_singlethread instead of C:\Development\Qt\6.6.1\wasm_singlethread
rem Second, need to specify an install prefix manually (e.g. C:\Development\Qt\Tools\CMake_64\bin\cmake.exe --install . --prefix "C:\\Development\\Qt\\6.6.1\\wasm_singlethread" --verbose for the final step).
rem See https://github.com/victronenergy/gui-v2/issues/441#issuecomment-1681609453 for full instructions.


rem (4) *** match _QTW_EMSDK_VERTSION to given _QTW_VERSION ***
rem todo:
rem  for Qt6.6 -> EMSDK 3.1.37
rem  see https://doc.qt.io/qt-6/wasm.html
set _QTW_EMSDK_VERTSION=3.1.37


rem (5) *** ensure EMSDK is available ***
call "%MAKER_BUILD%\ensure_emsdk.bat" %_QTW_EMSDK_VERTSION% --no_errors %MAKER_ENV_VERBOSE%
if %ERRORLEVEL% NEQ 0 (
  echo warning: EMSDK is not available
  goto :qtw_exit
)


:qtw_rebuild
rem (6) *** ensure prerequisites (note that build_qt already ensures most of the prerequisites below) ***
rem 
rem echo.
rem echo rebuilding Qt %_QT_VERSION% from sources
rem echo see https://doc.qt.io/qt-6/windows-building.html
rem echo.
rem echo *** THIS REQUIRES VisualStudio 2019 or 2022 or Mingw-w64
rem echo *** THIS REQUIRES Python 3
rem echo *** THIS REQUIRES Cmake 3.22 or newer
rem echo *** OTPIONAL: Ninja
rem echo *** OTPIONAL: Perl
rem echo *** OTPIONAL: LLVM/Clang
rem echo *** OTPIONAL: Node.js
rem echo *** OTPIONAL: gRPC
rem echo *** OTPIONAL: Protobuf
rem echo *** OPTIONAL: gperf, bison, flex (for QtWebEngine)
rem echo.
rem ensure msvs version and amd64 target architecture
call "%MAKER_BUILD%\ensure_msvs.bat" GEQ2019 amd64 %MAKER_ENV_VERBOSE%
if %ERRORLEVEL% NEQ 0 (
  goto :qtw_exit
)
rem validate cmake
call "%MAKER_BUILD%\validate_cmake.bat" GEQ3.16 %MAKER_ENV_VERBOSE%
if %ERRORLEVEL% NEQ 0 (
  goto :qtw_exit
)
rem validate ninja
call "%MAKER_BUILD%\validate_ninja.bat" --no_errors %MAKER_ENV_VERBOSE%
if %ERRORLEVEL% NEQ 0 (
  echo warning: NINJA is not available
  rem goto :qtw_exit
)
rem validate python
call "%MAKER_BUILD%\validate_python.bat" 3 "%MSVS_TARGET_ARCHITECTURE%" %MAKER_ENV_VERBOSE%
if %ERRORLEVEL% NEQ 0 (
  echo warning: PYTHON is not available
  goto :qtw_exit
)
rem validate llvm (due error: set LLVM_INSTALL_DIR + need to set the FEATURE_clang and FEATURE_clangcpp CMake variable to ON to re-evaluate this checks)
call "%MAKER_BUILD%\ensure_llvm.bat" %QT_LLVM_VER% --no_errors %MAKER_ENV_VERBOSE%
if %ERRORLEVEL% NEQ 0 (
  echo warning: LLVM CLANG is not available
  goto :qtw_exit
)
rem validate node.js 
call "%MAKER_BUILD%\ensure_nodejs.bat" GEQ14 --no_errors
if %ERRORLEVEL% NEQ 0 (
  echo warning: NODE.JS is not available
  goto :qtw_exit
)
rem ensure gperf (for QtWebEngine see https://stackoverflow.com/questions/73498046/building-qt5-from-source-qtwebenginecore-module-will-not-be-built-tool-gperf-i)
rem WARNING: QtWebEngine won't be built. Tool gperf is required.
call "%MAKER_BUILD%\ensure_gperf.bat" --no_errors
if %ERRORLEVEL% NEQ 0 (
  echo warning: GPERF is not available
  rem goto :qtw_exit
)
rem ensure bison
rem WARNING: QtWebEngine won't be built. Tool bison is required.
call "%MAKER_BUILD%\ensure_bison.bat" --no_errors
if %ERRORLEVEL% NEQ 0 (
  echo warning: BISON is not available
  rem goto :qtw_exit
)
rem esnure flex
rem Support check for QtWebEngine failed: Tool flex is required.
call "%MAKER_BUILD%\ensure_flex.bat" --no_errors
if %ERRORLEVEL% NEQ 0 (
  echo warning: FLEX is not available
  rem goto :qtw_exit
)
rem validate perl (for QNX/gperf see https://github.com/gperftools/gperftools/issues/1429)
rem call "%MAKER_BUILD%\validate_perl.bat" --no_errors %MAKER_ENV_VERBOSE%
rem if %ERRORLEVEL% NEQ 0 (
rem   echo warning: PERL is not available
rem   rem goto :qtw_exit
rem )


rem (7) *** configure QT-WASM ***
:qtw_configure_test
rem if exist "%_QTW_BUILD_DIR%\qtbase\cmake_install.cmake" echo QT-CONFIGURE WASM %_QTW_VERSION% already done &goto :qtw_build
:qtw_configure
echo QT-CONFIGURE WASM %_QTW_VERSION%
if not exist "%_QTW_BUILD_DIR%" mkdir "%_QTW_BUILD_DIR%"
if not exist "%_QTW_BUILD_DIR%\qtbase" mkdir "%_QTW_BUILD_DIR%\qtbase"
set "_QTW_LLVM_INSTALL_DIR=%LLVM_INSTALL_DIR:\=/%"
set "_QTW_CLANG_INSTALL_DIR=%_QTW_LLVM_INSTALL_DIR%"
set "_QTW_PREFIX_DIR=%_QTW_BUILD_DIR:\=/%qtbase"
set "_QTW_HOST_DIR=%QT_BIN_DIR:\=/%"
set _QTW_RETRIES=0
:qtw_configure_do
  cd /d "%_QTW_BUILD_DIR%"
  call "%_QTW_BUILD_DIR%\configure.bat" -qt-host-path "%_QTW_HOST_DIR%" -no-warnings-are-errors -platform wasm-emscripten -prefix "%_QTW_PREFIX_DIR%" -- -DLLVM_INSTALL_DIR="%_QTW_LLVM_INSTALL_DIR%" -DClang_DIR="%_QTW_LLVM_INSTALL_DIR%" --log-level=VERBOSE
  if exist "%_QT_BUILD_DIR%\qtmqtt\src\mqtt\cmake_install.cmake" goto :qtw_configure_done
  if "%_QTW_RETRIES%" equ "2" set _QTW_RETRIES=3
  if "%_QTW_RETRIES%" equ "1" set _QTW_RETRIES=2
  if "%_QTW_RETRIES%" equ "0" set _QTW_RETRIES=1
  if "%_QTW_RETRIES%" equ ""  set _QTW_RETRIES=1
  if "%_QTW_RETRIES%" equ "1" echo QT-CONFIGURE WASM incomplete after %_QTW_RETRIES% tries & goto :qtw_configure_done
  goto :qtw_configure_do
:qtw_configure_done


rem (8) *** build QT-WASM ***
:qtw_build
rem if exist "%QT_BIN_DIR%\bin\designer.exe" echo QT-BUILD WASM %_QTW_VERSION% already done &goto :qt_build_done
echo QT-BUILD WASM %_QTW_VERSION%
set _QTW_RETRIES=0
:qtw_build_do
  cd /d "%_QTW_BUILD_DIR%"
  call cmake --build . -t qtbase -t qtdeclarative
  rem https://doc.qt.io/qt-6/wasm.html#supported-qt-modules
  call cmake --build . -t qtCore -t qtGui -t qtNetwork -t qtWidgets -t qtQml -t qtQuick -t qtQuickControls -t qtQuickLayouts -t qt5CoreCompatibilityAPIs -t qtImageFormats -t qtOpenGL -t qtSVG -t qtWebSockets -t qt6Mqtt
  rem future WASM supported modules:
  rem call cmake --build . -t qtThreading -t qtConcurrent -t qtEmscriptenAsyncify -t qtSockets
  rem if exist "%_QTW_BUILD_DIR%\qtbase\bin\qtloader.js" goto :qtw_build_done
  if "%_QTW_RETRIES%" equ "2" set _QTW_RETRIES=3
  if "%_QTW_RETRIES%" equ "1" set _QTW_RETRIES=2
  if "%_QTW_RETRIES%" equ "0" set _QTW_RETRIES=1
  if "%_QTW_RETRIES%" equ ""  set _QTW_RETRIES=1
  if "%_QTW_RETRIES%" equ "1" echo QT-BUILD WASM incomplete after %_QTW_RETRIES% tries & goto :qtw_build_done
  goto :qtw_build_do
:qtw_build_done


rem (9) *** install QT-WASM ***
:qtw_install
rem if ... echo QT-INSTALL echo QT-INSTALL WASM %_QTW_VERSION% already done
rem call cmake --install "%_QTW_BUILD_DIR%" --prefix "%_QTW_BIN_DIR%" --verbose
:qtw_install_done


:qtw_exit
rem cd /d "%QT_DIR%"
cd /d "%_QTW_START_DIR%"
call "%MAKER_SCRIPTS%\clear_temp_envs.bat" "_QTW_" 1>nul 2>nul
