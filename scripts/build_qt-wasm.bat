@rem https://doc.qt.io/qt-6/wasm.html
@echo off
call "%~dp0\maker_env.bat" %*

call "%MAKER_SCRIPTS%\clear_temp_envs.bat" "_QTW_" 1>nul 2>nul
set "_QTW_START_DIR=%cd%"

if "%MAKER_ENV_VERBOSE%" neq "" echo on

set "QTW_VERSION=%MAKER_ENV_VERSION%"
set "_QTW_REBUILD=%MAKER_ENV_REBUILD%"


rem (1) *** define QT-WASM version defaults and clone options ***
rem set "_QTW_CLONE_OPTIONS=--silent --init_submodules --clone_submodules"
rem if "%_QTW_REBUILD%" neq "" set "_QTW_CLONE_OPTIONS=--silent --clean_before_clone --init_submodules --clone_submodules"
set "_QTW_CLONE_OPTIONS=--silent"
if "%_QTW_REBUILD%" neq "" set "_QTW_CLONE_OPTIONS=--silent --clean_before_clone"
rem version default:
rem if "%QTW_VERSION%" equ "" set QTW_VERSION=6.6.3
if "%QTW_VERSION%" equ "" set QTW_VERSION=6.8.3


rem (2) *** match QTW_EMSDK_VERSION to given QTW_VERSION ***
rem todo:
rem  for Qt6.6 -> EMSDK 3.1.37
rem  for Qt6.8 -> EMSDK 3.1.56
rem  see https://doc.qt.io/qt-6/wasm.html
set QTW_EMSDK_VERSION=3.1.37
set QTW_EMSDK_VERSION=3.1.56
set _QTW_GCC_VERSION=


rem (3) *** ensure GCC (MinGW64) ***
:qtw_ensure_mingw_gcc
rem the qt build and ensure scripts are not working properly, we have to call it twice
call "%MAKER_BUILD%\ensure_gcc.bat" %_QTW_GCC_VERSION% --no_errors %MAKER_ENV_VERBOSE% --
rem call "%MAKER_BUILD%\ensure_gcc.bat" %_QTW_GCC_VERSION% --no_errors %MAKER_ENV_VERBOSE% -- 1>nul 2>nul
if %ERRORLEVEL% NEQ 0 (
  echo warning: GCC is not available
  goto :qtw_exit
)

rem goto :qtw_clone_qt_wasm

rem (4) *** ensure QT Host ***
rem we need a QT Host version of same version as the target QT-QWASM we like to build (but build with MinGW gcc!)
:qtw_ensure_qt_host
call "%MAKER_BUILD%\ensure_qt.bat" %QTW_VERSION% %MAKER_ENV_VERBOSE% --use_gcc
if %ERRORLEVEL% NEQ 0 (
  echo building Qt %QTW_VERSION% failed
  goto :qtw_exit
)
rem defines: QT_DIR
rem defines: QT_SOURCES_DIR
rem defines: QT_BIN_DIR
rem defines: QT_VERSION
rem defines: QT_CMAKE
rem defines: QT_LLVM_VER
if "%QT_BIN_DIR%" EQU "" (echo error: Qt %QTW_VERSION% not available &goto :qtw_exit)
if not exist "%QT_BIN_DIR%" (echo error: Qt %QTW_VERSION% not available &goto :qtw_exit)
if not exist "%QT_BIN_DIR%\lib\cmake\Qt6Mqtt\Qt6MqttConfig.cmake" (echo error: Qt %QTW_VERSION% incomplete &goto :qtw_exit)
if not exist "%QT_BIN_DIR%\bin\Qt6WebSockets.dll" (echo error: Qt %QTW_VERSION% incomplete &goto :qtw_exit)
set "QTW_HOST_DIR=%QT_BIN_DIR:\=/%"


rem (5) *** clone qt sources for wasm-build ***
:qtw_clone_qt_wasm
call "%MAKER_BUILD%\clone_qt.bat" "%QTW_VERSION%" "qt-wasm" %MAKER_ENV_VERBOSE% %_QTW_CLONE_OPTIONS%
rem defines: QT_DIR
rem defines: QT_SOURCES_DIR
rem clone_qt might switch folder so we switch back:
cd /d "%_QTW_START_DIR%"
rem with QT-WASM the Build-Dir is the Source_Dir
set "QTW_SOURCES_DIR=%QT_SOURCES_DIR%"
set "QTW_BUILD_DIR=%QT_SOURCES_DIR%"
set "QTW_BIN_DIR=%QTW_BUILD_DIR%qtbase"
rem we clone also qt-wasm-examples
set "QTW_EXAMPLES_DIR=%QT_DIR%\qt-webassembly-examples"
call "%MAKER_SCRIPTS%\clone_in_folder.bat" "%QTW_EXAMPLES_DIR%" "https://github.com/msorvig/qt-webassembly-examples.git" %MAKER_ENV_VERBOSE% --silent

rem show what we have so far
if "%MAKER_ENV_VERBOSE%" neq "" set QTW_
if "%MAKER_ENV_VERBOSE%" neq "" set _QTW_


rem (6) *** patch QT-WASM CMake files ***
rem https://ronakshah1009.wordpress.com/2020/07/28/build-wasm-on-windows-for-qt
rem
rem Note:
rem https://github.com/victronenergy/gui-v2/wiki/How-to-build-venus-gui-v2#building-for-webassembly
rem Building qt 6.6.1 for wasm_singlethread on Windows 10/11 seems to have a couple of quirks.
rem First, need to edit ~/Qt/6.6.1/wasm_singlethread/lib/cmake/Qt6BuildInternals/QtBuildInternalsExtra.cmake to ensure that the Qt paths are properly escaped (e.g. C:\\Development\\Qt\\6.6.1\\wasm_singlethread instead of C:\Development\Qt\6.6.1\wasm_singlethread
rem Second, need to specify an install prefix manually (e.g. C:\Development\Qt\Tools\CMake_64\bin\cmake.exe --install . --prefix "C:\\Development\\Qt\\6.6.1\\wasm_singlethread" --verbose for the final step).
rem See https://github.com/victronenergy/gui-v2/issues/441#issuecomment-1681609453 for full instructions.

:qtw_rebuild
rem (7) *** ensure prerequisites (note that build_qt already ensures most of the prerequisites below) ***
rem 
echo.
echo rebuilding Qt-WASM %QTW_VERSION% from sources
echo see https://doc.qt.io/qt-6/wasm.html
echo.
echo *** THIS REQUIRES EMSDK in proper version matching QT-Version ***
echo *** THIS REQUIRES GCC (MinGW)
echo *** THIS REQUIRES SED
echo *** THIS REQUIRES LLVM/Clang
echo *** THIS REQUIRES Cmake 3.22 or newer
echo *** THIS REQUIRES Ninja
call "%MAKER_BUILD%\validate_cmake.bat" GEQ3.16 %MAKER_ENV_VERBOSE%
if %ERRORLEVEL% NEQ 0 (
  echo error: CMAKE GEQ3.16 is not available
  goto :qtw_exit
)
call "%MAKER_BUILD%\validate_ninja.bat" --no_errors %MAKER_ENV_VERBOSE%
if %ERRORLEVEL% NEQ 0 (
  echo error: NINJA is not available
  goto :qtw_exit
)
call "%MAKER_BUILD%\ensure_llvm.bat" %QT_LLVM_VER% --no_errors %MAKER_ENV_VERBOSE% --
if %ERRORLEVEL% NEQ 0 (
  echo êrror: LLVM CLANG is not available
  goto :qtw_exit
)
call "%MAKER_BUILD%\ensure_gcc.bat" %_QTW_GCC_VERSION% --no_errors %MAKER_ENV_VERBOSE% --
if %ERRORLEVEL% NEQ 0 (
  echo error: GCC is not available
  goto :qtw_exit
)
echo on
call "%MAKER_BUILD%\ensure_emsdk.bat" %QTW_EMSDK_VERSION% --no_errors %MAKER_ENV_VERBOSE%
if %ERRORLEVEL% NEQ 0 (
  echo error: EMSDK is not available
  goto :qtw_exit
)
rem echo *** OTPIONAL: VisualStudio 2019 or 2022
rem echo *** OTPIONAL: Node.js
rem echo *** OTPIONAL: Python 3
rem echo *** OTPIONAL: Perl
rem echo *** OTPIONAL: gRPC
rem echo *** OTPIONAL: Protobuf
rem echo *** OPTIONAL: gperf, bison, flex (for QtWebEngine)
rem echo.
rem ensure msvs version and amd64 target architecture
rem call "%MAKER_BUILD%\ensure_msvs.bat" GEQ2019 amd64 %MAKER_ENV_VERBOSE%
rem if %ERRORLEVEL% NEQ 0 (
rem   goto :qtw_exit
rem )
call "%MAKER_BUILD%\validate_python.bat" 3 "%MSVS_TARGET_ARCHITECTURE%" %MAKER_ENV_VERBOSE%
if %ERRORLEVEL% NEQ 0 (
  echo warning: PYTHON is not available
  rem goto :qtw_exit
)
call "%MAKER_BUILD%\validate_nodejs.bat" GEQ14 --no_errors %MAKER_ENV_VERBOSE%
if %ERRORLEVEL% NEQ 0 (
  echo warning: NODE.JS is not available
  rem goto :qtw_exit
)
call "%MAKER_BUILD%\validate_gperf.bat" --no_errors %MAKER_ENV_VERBOSE%
if %ERRORLEVEL% NEQ 0 (
  echo warning: GPERF is not available
  rem goto :qtw_exit
)
call "%MAKER_BUILD%\validate_bison.bat" --no_errors %MAKER_ENV_VERBOSE%
if %ERRORLEVEL% NEQ 0 (
  echo warning: BISON is not available
  rem goto :qtw_exit
)
call "%MAKER_BUILD%\validate_flex.bat" --no_errors %MAKER_ENV_VERBOSE%
if %ERRORLEVEL% NEQ 0 (
  echo warning: FLEX is not available
  rem goto :qtw_exit
)
call "%MAKER_BUILD%\validate_perl.bat" --no_errors %MAKER_ENV_VERBOSE%
if %ERRORLEVEL% NEQ 0 (
  echo warning: PERL is not available
  rem goto :qtw_exit
)


rem (8) *** configure QT-WASM ***
:qtw_configure_test
if exist "%QTW_BUILD_DIR%\qtbase\cmake_install.cmake" echo QT-CONFIGURE WASM %QTW_VERSION% already done &goto :qtw_configure_done
:qtw_configure
echo QT-CONFIGURE WASM %QTW_VERSION%
rem if not exist "%QTW_BUILD_DIR%" mkdir "%QTW_BUILD_DIR%"
rem if not exist "%QTW_BUILD_DIR%\qtbase" mkdir "%QTW_BUILD_DIR%\qtbase"
set "_QTW_LLVM_INSTALL_DIR=%LLVM_INSTALL_DIR:\=/%"
set "_QTW_CLANG_INSTALL_DIR=%_QTW_LLVM_INSTALL_DIR%"
set "_QTW_PREFIX_DIR=%QTW_BUILD_DIR:\=/%qtbase"
set "_QTW_HOST_DIR=%QT_BIN_DIR:\=/%"
set _QTW_RETRIES=0
:qtw_configure_do
  cd /d "%QTW_BUILD_DIR%"
  rem call "%QTW_BUILD_DIR%\configure.bat" -qt-host-path "%_QTW_HOST_DIR%" -no-warnings-are-errors -platform wasm-emscripten -prefix "%_QTW_PREFIX_DIR%" -- -DLLVM_INSTALL_DIR="%_QTW_LLVM_INSTALL_DIR%" -DClang_DIR="%_QTW_LLVM_INSTALL_DIR%" --log-level=VERBOSE
  rem call "%QTW_BUILD_DIR%\configure.bat" -qt-host-path "%_QTW_HOST_DIR%" -no-warnings-are-errors -xplatform wasm-emscripten -platform win32 -prefix "%_QTW_PREFIX_DIR%" -- -DLLVM_INSTALL_DIR="%_QTW_LLVM_INSTALL_DIR%" -DClang_DIR="%_QTW_LLVM_INSTALL_DIR%" --log-level=VERBOSE
  rem call "%QTW_BUILD_DIR%\configure.bat" -qt-host-path "%_QTW_HOST_DIR%" -no-warnings-are-errors -xplatform wasm-emscripten -platform win32-g++ -prefix "%_QTW_PREFIX_DIR%" -nomake examples -- -DLLVM_INSTALL_DIR="%_QTW_LLVM_INSTALL_DIR%" -DClang_DIR="%_QTW_LLVM_INSTALL_DIR%" --log-level=VERBOSE
  rem maybe try above with explicite mingw32-make

  rem this is from "https://ronakshah1009.wordpress.com/2020/07/28/build-wasm-on-windows-for-qt"
  rem call "%QTW_BUILD_DIR%\configure.bat" -no-warnings-are-errors -xplatform wasm-emscripten -platform win32-g++ -nomake examples -prefix %CD%\qtbase mingw32-make module-qtbase module-qtdeclarative
  rem call "%QTW_BUILD_DIR%\configure.bat" -no-warnings-are-errors -xplatform wasm-emscripten -platform win32-g++ -nomake examples -prefix "%_QTW_PREFIX_DIR%" mingw32-make module-qtbase module-qtdeclarative -- -DLLVM_INSTALL_DIR="%_QTW_LLVM_INSTALL_DIR%" -DClang_DIR="%_QTW_LLVM_INSTALL_DIR%" --log-level=VERBOSE
  rem call "%QTW_BUILD_DIR%\configure.bat" -no-warnings-are-errors -xplatform wasm-emscripten -platform win32-g++ -nomake examples -prefix "%_QTW_PREFIX_DIR%" mingw32-make module-qtbase module-qtdeclarative
  rem call "%QTW_BUILD_DIR%\configure.bat" -no-warnings-are-errors -xplatform wasm-emscripten -platform win32-g++ -nomake examples -prefix "%_QTW_PREFIX_DIR%"

  echo DEBUG CONFIGURE SETTINGS
  set _QT_
  set _QTW_
  set QT_
  set QTW_
  path
  call "%QTW_BUILD_DIR%\configure.bat" -qt-host-path "%QTW_HOST_DIR%" -no-warnings-are-errors -platform wasm-emscripten -nomake examples -prefix "%_QTW_PREFIX_DIR%"
  
  rem ... -t qtCore -t qtGui -t qtNetwork -t qtWidgets -t qtQml -t qtQuick -t qtQuickControls -t qtQuickLayouts -t qt5CoreCompatibilityAPIs -t qtImageFormats -t qtOpenGL -t qtSVG -t qtWebSockets -t qt6Mqtt
  rem ...future WASM supported modules -t qtThreading -t qtConcurrent -t qtEmscriptenAsyncify -t qtSockets
  if not exist "%_QT_BUILD_DIR%\qtbase\lib\cmake\Qt6Core\Qt6CoreConfig.cmake" goto :qtw_configure_retry
  if not exist "%_QT_BUILD_DIR%\qtbase\lib\cmake\Qt6Gui\Qt6GuiConfig.cmake" goto :qtw_configure_retry
  if not exist "%_QT_BUILD_DIR%\qtbase\lib\cmake\Qt6Network\Qt6NetworkConfig.cmake" goto :qtw_configure_retry
  if not exist "%_QT_BUILD_DIR%\qtbase\lib\cmake\Qt6Widgets\Qt6WidgetsConfig.cmake" goto :qtw_configure_retry
  if not exist "%_QT_BUILD_DIR%\qtbase\lib\cmake\Qt6Qml\Qt6QmlConfig.cmake" goto :qtw_configure_retry
  if not exist "%_QT_BUILD_DIR%\qtbase\lib\cmake\Qt6Quick\Qt6QuickConfig.cmake" goto :qtw_configure_retry
  if not exist "%_QT_BUILD_DIR%\qtbase\lib\cmake\Qt6QuickControls2\Qt6QuickControls2Config.cmake" goto :qtw_configure_retry
  if not exist "%_QT_BUILD_DIR%\qtbase\lib\cmake\Qt6QuickLayouts\Qt6QuickLayoutsConfig.cmake" goto :qtw_configure_retry
  if not exist "%_QT_BUILD_DIR%\qtbase\lib\cmake\Qt6Core5Compat\Qt6Core5CompatConfig.cmake" goto :qtw_configure_retry
  if not exist "%_QT_BUILD_DIR%\qtbase\lib\cmake\Qt6ImageFormats\Qt6ImageFormatsConfig.cmake" goto :qtw_configure_retry
  if not exist "%_QT_BUILD_DIR%\qtbase\lib\cmake\Qt6OpenGL\Qt6OpenGLConfig.cmake" goto :qtw_configure_retry
  if not exist "%_QT_BUILD_DIR%\qtbase\lib\cmake\Qt6Svg\Qt6SvgConfig.cmake" goto :qtw_configure_retry
  if not exist "%_QT_BUILD_DIR%\qtbase\lib\cmake\Qt6WebSockets\Qt6WebSocketsConfig.cmake" goto :qtw_configure_retry
  if not exist "%_QT_BUILD_DIR%\qtbase\lib\cmake\Qt6Mqtt\Qt6MqttConfig.cmake" goto :qtw_configure_retry
  rem if not exist "%_QT_BUILD_DIR%\qtbase\lib\cmake\Qt6DBus\Qt6DBusConfig.cmake" goto :qtw_configure_retry
  goto :qtw_configure_done
:qtw_configure_retry
  if "%_QTW_RETRIES%" equ "2" set _QTW_RETRIES=3
  if "%_QTW_RETRIES%" equ "1" set _QTW_RETRIES=2
  if "%_QTW_RETRIES%" equ "0" set _QTW_RETRIES=1
  if "%_QTW_RETRIES%" equ ""  set _QTW_RETRIES=1
  if "%_QTW_RETRIES%" equ "2" echo QT-CONFIGURE WASM incomplete after %_QTW_RETRIES% tries & goto :qtw_configure_done
  goto :qtw_configure_do
:qtw_configure_done


rem test to not build it
goto :qtw_install


rem (9) *** build QT-WASM ***
:qtw_build_test
if exist "%QTW_BIN_DIR%\bin\qtloader.js" echo QT-BUILD WASM %QTW_VERSION% already done &goto :qtw_build_done
:qtw_build
rem if exist "%QT_BIN_DIR%\bin\designer.exe" echo QT-BUILD WASM %QTW_VERSION% already done &goto :qt_build_done
echo QT-BUILD WASM %QTW_VERSION%
set _QTW_RETRIES=0
:qtw_build_do
  cd /d "%QTW_BUILD_DIR%"
  call cmake --build . -t qtbase -t qtdeclarative
  rem https://doc.qt.io/qt-6/wasm.html#supported-qt-modules
  rem call cmake --build . -t qtCore -t qtGui -t qtNetwork -t qtWidgets -t qtQml -t qtQuick -t qtQuickControls -t qtQuickLayouts -t qt5CoreCompatibilityAPIs -t qtImageFormats -t qtOpenGL -t qtSVG -t qtWebSockets -t qt6Mqtt
  rem future WASM supported modules:
  rem call cmake --build . -t qtThreading -t qtConcurrent -t qtEmscriptenAsyncify -t qtSockets
  if exist "%QTW_BUILD_DIR%\qtbase\bin\qtloader.js" goto :qtw_build_done
  if "%_QTW_RETRIES%" equ "2" set _QTW_RETRIES=3
  if "%_QTW_RETRIES%" equ "1" set _QTW_RETRIES=2
  if "%_QTW_RETRIES%" equ "0" set _QTW_RETRIES=1
  if "%_QTW_RETRIES%" equ ""  set _QTW_RETRIES=1
  if "%_QTW_RETRIES%" equ "1" echo QT-BUILD WASM incomplete after %_QTW_RETRIES% tries & goto :qtw_build_done
  goto :qtw_build_do
:qtw_build_done


rem (10) *** install QT-WASM ***
:qtw_install
if "%QTW_BIN_DIR%" equ "" exit /b 99
if not exist "%QTW_BIN_DIR%" exit /b 100
if not exist "%QTW_BIN_DIR%\bin" exit /b 101
if not exist "%QTW_BIN_DIR%\bin\qtloader.js" exit /b 102

set "_QTW_TEST_TOOL=qmake"
call "%~dp0\core\generic_validate.bat" "_QTWASM" "%_QTW_TEST_TOOL% --version" "for /f ""tokens=1,2,3,4,* delims= "" %%%%i in ('call %_QTW_TEST_TOOL% --version') do if /I %%%%j EQU Qt if /I %%%%k EQU version echo %%%%l" %QTW_VERSION% %MAKER_ENV_VERBOSE% 1>nul 2>nul
if %ERRORLEVEL% NEQ 0 set "path=%QTW_BIN_DIR%\bin;%path%"
set _QTW_TEST_TOOL=
call "%MAKER_SCRIPTS%\clear_temp_envs.bat" "_QTWASM" 1>nul 2>nul
call "%~dp0\validate_qt-wasm.bat" %QTW_VERSION% %MAKER_ENV_VERBOSE%
exit /b %ERRORLEVEL%
:qtw_install_done


:qtw_exit
rem cd /d "%QT_DIR%"
cd /d "%_QTW_START_DIR%"
call "%MAKER_SCRIPTS%\clear_temp_envs.bat" "_QTW_" 1>nul 2>nul
