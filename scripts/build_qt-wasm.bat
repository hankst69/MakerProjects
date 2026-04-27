@rem https://doc.qt.io/qt-6/wasm.html
@echo off
call "%~dp0\maker_env.bat" %*
call "%MAKER_ENV_CORE%\clear_temp_envs.bat" "_QTW_" 1>nul 2>nul
set "_QTW_START_DIR=%cd%"
set "_QTW_VERSION=%MAKER_VERSION%"
set "_QTW_REBUILD=%MAKER_REBUILD%"
set "_QTW_BUILD_ARCH=%MAKER_BUILD_ARCH%"
set "_QTW_BUILD_TYPE=%MAKER_BUILD_TYPE%"
set "_QTW_BUILD_MODE=%MAKER_BUILD_MODE%"
set "_QTW_BUILD_SYSTEM=%MAKER_BUILD_SYSTEM%"
set "_QTW_BUILD_CONFIG=%MAKER_BUILD_CONFIG%"

call "%MAKER_ENV_CORE%\stop_watch.bat"
set "_QTW_BUILD_DATE_START=%_DATE_%"
set "_QTW_BUILD_TIME_START=%_TIME_UI%"
set "_QTW_BUILD_DATETIME_START=%_DATETIME_%"


rem (1) *** define QT-WASM version ***
set "QTW_VERSION=%_MAKER_VERSION%"
rem if "%QTW_VERSION%" equ "" set QTW_VERSION=6.6.3
if "%QTW_VERSION%" equ "" set QTW_VERSION=6.8.3

rem (2) *** define QT-WASM version clone options ***
set "_QTW_CLONE_OPTIONS=--silent --init_submodules --clone_submodules"
set "_QTW_CLONE_OPTIONS=--silent --init_submodules"
rem set "_QTW_CLONE_OPTIONS=--silent"
if "%_QTW_REBUILD%" neq "" set "_QTW_CLONE_OPTIONS=%_QTW_CLONE_OPTIONS% --clean_before_clone"

rem (3) *** match QTW_EMSDK_VERSION to given QTW_VERSION ***
rem
rem  see https://doc.qt.io/qt-6/wasm.html
rem  see https://github.com/victronenergy/gui-v2/blob/main/scripts/.env
rem  for Qt6.6 -> EMSDK 3.1.37
rem  for Qt6.8 -> EMSDK 3.1.56
set QTW_EMSDK_VERSION=3.1.56
if "%MAKER_VERSION_MAJOR%_%MAKER_VERSION_MINOR%" equ "6_6" set QTW_EMSDK_VERSION=3.1.37
set _QTW_GCC_VERSION=

rem if "%MAKER_MSG_VERBOSE%" neq "" echo on


rem (4) *** clone qt sources for wasm-build ***
:qtw_clone_qt_wasm
echo clone_qt "%QTW_VERSION%" "wasm" %MAKER_MSG_VERBOSE% %_QTW_CLONE_OPTIONS%
call "%MAKER_DIR_SCRIPTS%\clone_qt.bat" "%QTW_VERSION%" "wasm" %MAKER_MSG_VERBOSE% %_QTW_CLONE_OPTIONS%
rem defines: QT_DIR
rem defines: QT_SOURCES_DIR
rem clone_qt might switch folder so we switch back:
cd /d "%_QTW_START_DIR%"
rem with QT-WASM the Build-Dir is the Source_Dir
set "QTW_SOURCES_DIR=%QT_SOURCES_DIR%"
set "QTW_BUILD_DIR=%QT_SOURCES_DIR%"
set "QTW_BIN_DIR=%QTW_BUILD_DIR%"

rem we clone also qt-wasm-examples
set "QTW_EXAMPLES_DIR=%MAKER_DIR_PROJECTS%\Qt\qt-webassembly-examples"
set "QTW_EXAMPLES_DIR=%QT_DIR%\qt-webassembly-examples"
call "%MAKER_ENV_CORE%\clone_in_folder.bat" "%QTW_EXAMPLES_DIR%" "https://github.com/msorvig/qt-webassembly-examples.git" %MAKER_MSG_VERBOSE% --silent


rem (4) *** test for build necessarity ***
echo.
echo QT-WASM %QTW_VERSION% - testing INSTALLATION: %_QTW_TEE_LOG%
if not exist "%QTW_BIN_DIR%\bin\qmake.bat" echo missing libQt6Mqtt.a %_QTW_TEE_LOG% &goto qtw_rebuild
if not exist "%QTW_BIN_DIR%\lib\libQt6Core.a" echo missing libQt6Mqtt.a %_QTW_TEE_LOG% &goto qtw_rebuild
if not exist "%QTW_BIN_DIR%\lib\libQt6Mqtt.a" echo missing libQt6Mqtt.a %_QTW_TEE_LOG% &goto qtw_rebuild
if not exist "%QTW_BUILD_DIR%\plugins\imageformats\libqtga.a" echo missing libqtga.a %_QTW_TEE_LOG% &goto qtw_rebuild
goto :qtw_setup


:qtw_rebuild
rem (5) *** rebuild QT-WASM  ***
set "_QTW_LOGFILE=%QT_DIR%\.logs\qt-wasm_build_%_QTW_VERSION%_%_QTW_BUILD_CONFIG%_%_QTW_BUILD_DATETIME_START%.log"
if not exist "%QT_DIR%\.logs" mkdir "%QT_DIR%\.logs"
echo.%_QTW_BUILD_DATE_START% %_QTW_BUILD_TIME_START% >"%_QTW_LOGFILE%"
set _QTW_TEE_LOG=^| "%MAKER_ENV_CORE%\tee.bat" "%_QTW_LOGFILE%"
echo.
echo rebuilding QT-WASM %QTW_VERSION% from sources %_QTW_TEE_LOG%
echo see https://doc.qt.io/qt-6/wasm.html %_QTW_TEE_LOG%
echo.
echo *** THIS REQUIRES QT %QTW_VERSION% gnu %_QTW_TEE_LOG%
echo *** THIS REQUIRES EMSDK in proper version matching QT-Version *** %_QTW_TEE_LOG%
echo *** THIS REQUIRES GCC (MinGW) %_QTW_TEE_LOG%
echo *** THIS REQUIRES SED %_QTW_TEE_LOG%
echo *** THIS REQUIRES LLVM/Clang %_QTW_TEE_LOG%
echo *** THIS REQUIRES Cmake 3.22 or newer %_QTW_TEE_LOG%
echo *** THIS REQUIRES Ninja %_QTW_TEE_LOG%

rem (6) *** ensure QT Host ***
rem we need a QT Host version of same version as the target QT-QWASM (for cross compilation) build with MinGW gcc!
:qtw_ensure_qt_host
call "%MAKER_DIR_SCRIPTS%\ensure_qt.bat" %QTW_VERSION% gnu %MAKER_MSG_VERBOSE%
if %ERRORLEVEL% NEQ 0 (
  echo building Qt %QTW_VERSION% failed %_QTW_TEE_LOG%
  goto :qtw_exit
)
rem defines: QT_DIR
rem defines: QT_SOURCES_DIR
rem defines: QT_BIN_DIR
rem defines: QT_VERSION
rem defines: QT_CMAKE
rem defines: QT_LLVM_VER
if "%QT_BIN_DIR%" EQU "" (echo error: Qt %QTW_VERSION% not available %_QTW_TEE_LOG% &goto :qtw_exit)
if not exist "%QT_BIN_DIR%" (echo error: Qt %QTW_VERSION% not available %_QTW_TEE_LOG% &goto :qtw_exit)
if not exist "%QT_BIN_DIR%\lib\cmake\Qt6Mqtt\Qt6MqttConfig.cmake" (echo error: Qt %QTW_VERSION% incomplete %_QTW_TEE_LOG% &goto :qtw_exit)
if not exist "%QT_TEST_LIB_MQTT%" (echo error: Qt %QTW_VERSION% incomplete %_QTW_TEE_LOG% &goto :qtw_exit)

set "QTW_HOST_DIR=%QT_BIN_DIR:\=/%"

rem show what we have so far
if "%MAKER_MSG_VERBOSE%" neq "" set QT_
if "%MAKER_MSG_VERBOSE%" neq "" set QTW_
if "%MAKER_MSG_VERBOSE%" neq "" set _QTW_


rem (7) *** patch QT-WASM CMake files ***
rem https://ronakshah1009.wordpress.com/2020/07/28/build-wasm-on-windows-for-qt
rem
rem Note:
rem https://github.com/victronenergy/gui-v2/wiki/How-to-build-venus-gui-v2#building-for-webassembly
rem Building qt 6.6.1 for wasm_singlethread on Windows 10/11 seems to have a couple of quirks.
rem First, need to edit ~/Qt/6.6.1/wasm_singlethread/lib/cmake/Qt6BuildInternals/QtBuildInternalsExtra.cmake to ensure that the Qt paths are properly escaped (e.g. C:\\Development\\Qt\\6.6.1\\wasm_singlethread instead of C:\Development\Qt\6.6.1\wasm_singlethread
rem Second, need to specify an install prefix manually (e.g. C:\Development\Qt\Tools\CMake_64\bin\cmake.exe --install . --prefix "C:\\Development\\Qt\\6.6.1\\wasm_singlethread" --verbose for the final step).
rem See https://github.com/victronenergy/gui-v2/issues/441#issuecomment-1681609453 for full instructions.

:qtw_rebuild
rem (8) *** ensure prerequisites (note that build_qt already ensures most of the prerequisites below) ***
rem 
call "%MAKER_DIR_SCRIPTS%\validate_cmake.bat" GEQ3.16 %MAKER_MSG_VERBOSE%
if %ERRORLEVEL% NEQ 0 (
  echo error: CMAKE GEQ3.16 is not available %_QTW_TEE_LOG%
  goto :qtw_exit
)
call "%MAKER_DIR_SCRIPTS%\validate_ninja.bat" --no_errors %MAKER_MSG_VERBOSE%
if %ERRORLEVEL% NEQ 0 (
  echo error: NINJA is not available %_QTW_TEE_LOG%
  goto :qtw_exit
)
call "%MAKER_DIR_SCRIPTS%\ensure_llvm.bat" %QT_LLVM_VER% gnu --no_errors %MAKER_MSG_VERBOSE%
if %ERRORLEVEL% NEQ 0 (
  echo êrror: LLVM CLANG is not available %_QTW_TEE_LOG%
  goto :qtw_exit
)
call "%MAKER_DIR_SCRIPTS%\ensure_gcc.bat" %_QTW_GCC_VERSION% --no_errors %MAKER_MSG_VERBOSE%
if %ERRORLEVEL% NEQ 0 (
  echo error: GCC is not available %_QTW_TEE_LOG%
  goto :qtw_exit
)
call "%MAKER_DIR_SCRIPTS%\ensure_emsdk.bat" %QTW_EMSDK_VERSION% --no_errors %MAKER_MSG_VERBOSE%
if %ERRORLEVEL% NEQ 0 (
  echo error: EMSDK is not available %_QTW_TEE_LOG%
  goto :qtw_exit
)
rem echo *** OTPIONAL: Node.js
rem echo *** OTPIONAL: Python 3
rem echo *** OTPIONAL: Perl
rem echo *** OTPIONAL: gRPC
rem echo *** OTPIONAL: Protobuf
rem echo *** OPTIONAL: gperf, bison, flex (for QtWebEngine)
call "%MAKER_DIR_SCRIPTS%\validate_python.bat" 3 "%MSVS_TARGET_ARCHITECTURE%" %MAKER_MSG_VERBOSE%
if %ERRORLEVEL% NEQ 0 (
  echo warning: PYTHON is not available %_QTW_TEE_LOG%
  rem goto :qtw_exit
)
call "%MAKER_DIR_SCRIPTS%\validate_nodejs.bat" GEQ14 --no_errors %MAKER_MSG_VERBOSE%
if %ERRORLEVEL% NEQ 0 (
  echo warning: NODE.JS is not available %_QTW_TEE_LOG%
  rem goto :qtw_exit
)
call "%MAKER_DIR_SCRIPTS%\validate_gperf.bat" gnu --no_errors %MAKER_MSG_VERBOSE%
if %ERRORLEVEL% NEQ 0 (
  echo warning: GPERF is not available %_QTW_TEE_LOG%
  rem goto :qtw_exit
)
call "%MAKER_DIR_SCRIPTS%\validate_bison.bat" gnu --no_errors %MAKER_MSG_VERBOSE%
if %ERRORLEVEL% NEQ 0 (
  echo warning: BISON is not available %_QTW_TEE_LOG%
  rem goto :qtw_exit
)
call "%MAKER_DIR_SCRIPTS%\validate_flex.bat" gnu --no_errors %MAKER_MSG_VERBOSE%
if %ERRORLEVEL% NEQ 0 (
  echo warning: FLEX is not available %_QTW_TEE_LOG%
  rem goto :qtw_exit
)
call "%MAKER_DIR_SCRIPTS%\validate_perl.bat" --no_errors %MAKER_MSG_VERBOSE%
if %ERRORLEVEL% NEQ 0 (
  echo warning: PERL is not available %_QTW_TEE_LOG%
  rem goto :qtw_exit
)


rem (9) *** configure QT-WASM ***
rem
rem https://wiki.qt.io/Qt_6.8_Tools_and_Versions#Software_configurations_for_Qt_6.8.3
rem ID                    = webassembly-windows	
rem Dependencies          = windows-10_22h2-mingw13	
rem Target                = WebAssembly (clang-x86_64)	
rem Host                  = Windows_10_22H2 (mingw-x86_64)	
rem Coin Options          = Packaging, Sccache, DisableTests, UseConfigure, GenerateSBOM, VerifySBOM		
rem Configure Arguments   = 
rem Environment Variables = Path=Template:.Env.EMSDK PATH;Template:.Env.MINGW PATH\bin;Template:.Env.Path, EM_CONFIG=Template:.Env.EMSDK/.emscripten, TARGET_CONFIGURE_ARGS=-release -platform wasm-emscripten -nomake examples, TARGET_CMAKE_ARGS=-DQT_GENERATE_WRAPPER_SCRIPTS_FOR_ALL_HOSTS=ON, NON_QTBASE_TARGET_CMAKE_ARGS=-DFEATURE_pkg_config=OFF -DQT_ADDITIONAL_HOST_PACKAGES_PREFIX_PATH=Template:.Env.Protobuf ROOT mingw -DQT_PROTOBUF_WELL_KNOWN_TYPES_PROTO_DIR=Template:.Env.Protobuf ROOT mingw/include
rem 
:qtw_configure
rem if not exist "%QTW_BUILD_DIR%" mkdir "%QTW_BUILD_DIR%"
rem if not exist "%QTW_BUILD_DIR%\qtbase" mkdir "%QTW_BUILD_DIR%\qtbase"
set "_QTW_LLVM_INSTALL_DIR=%LLVM_INSTALL_DIR:\=/%"
rem set "_QTW_CLANG_INSTALL_DIR=%_QTW_LLVM_INSTALL_DIR%"
rem set "_QTW_PREFIX_DIR=%QTW_BUILD_DIR:\=/%qbase"
set "_QTW_PREFIX_DIR=%QTW_BUILD_DIR:\=/%"
set "_QTW_HOST_DIR=%QT_BIN_DIR:\=/%"
set _QTW_TRIES=2
set _QTW_TRY=0
goto :qtw_configure_test
:qtw_configure_do
  echo.
  echo ******************************************************************************** %_QTW_TEE_LOG%
  echo QT-CONFIGURE WASM %QTW_VERSION% (TRY %_QTW_TRY%) %_QTW_TEE_LOG%
  echo ******************************************************************************** %_QTW_TEE_LOG%
  cd /d "%QTW_BUILD_DIR%"
  rem https://doc.qt.io/qt-6/wasm.html
  rem call "%QTW_BUILD_DIR%\configure.bat" -qt-host-path "%_QTW_HOST_DIR%" -no-warnings-are-errors -platform wasm-emscripten -prefix "%_QTW_PREFIX_DIR%" -- -DLLVM_INSTALL_DIR="%_QTW_LLVM_INSTALL_DIR%" -DClang_DIR="%_QTW_LLVM_INSTALL_DIR%" --log-level=VERBOSE
  rem call "%QTW_BUILD_DIR%\configure.bat" -qt-host-path "%_QTW_HOST_DIR%" -no-warnings-are-errors -xplatform wasm-emscripten -platform win32 -prefix "%_QTW_PREFIX_DIR%" -- -DLLVM_INSTALL_DIR="%_QTW_LLVM_INSTALL_DIR%" -DClang_DIR="%_QTW_LLVM_INSTALL_DIR%" --log-level=VERBOSE
  rem call "%QTW_BUILD_DIR%\configure.bat" -qt-host-path "%_QTW_HOST_DIR%" -no-warnings-are-errors -xplatform wasm-emscripten -platform win32-g++ -prefix "%_QTW_PREFIX_DIR%" -nomake examples -- -DLLVM_INSTALL_DIR="%_QTW_LLVM_INSTALL_DIR%" -DClang_DIR="%_QTW_LLVM_INSTALL_DIR%" --log-level=VERBOSE
  rem maybe try above with explicite mingw32-make

  rem this is from "https://ronakshah1009.wordpress.com/2020/07/28/build-wasm-on-windows-for-qt"
  rem call "%QTW_BUILD_DIR%\configure.bat" -no-warnings-are-errors -xplatform wasm-emscripten -platform win32-g++ -nomake examples -prefix %CD%\qtbase mingw32-make module-qtbase module-qtdeclarative
  rem call "%QTW_BUILD_DIR%\configure.bat" -no-warnings-are-errors -xplatform wasm-emscripten -platform win32-g++ -nomake examples -prefix "%_QTW_PREFIX_DIR%" mingw32-make module-qtbase module-qtdeclarative -- -DLLVM_INSTALL_DIR="%_QTW_LLVM_INSTALL_DIR%" -DClang_DIR="%_QTW_LLVM_INSTALL_DIR%" --log-level=VERBOSE
  rem call "%QTW_BUILD_DIR%\configure.bat" -no-warnings-are-errors -xplatform wasm-emscripten -platform win32-g++ -nomake examples -prefix "%_QTW_PREFIX_DIR%" mingw32-make module-qtbase module-qtdeclarative
  rem call "%QTW_BUILD_DIR%\configure.bat" -no-warnings-are-errors -xplatform wasm-emscripten -platform win32-g++ -nomake examples -prefix "%_QTW_PREFIX_DIR%"

  rem ... -t qtCore -t qtGui -t qtNetwork -t qtWidgets -t qtQml -t qtQuick -t qtQuickControls -t qtQuickLayouts -t qt5CoreCompatibilityAPIs -t qtImageFormats -t qtOpenGL -t qtSVG -t qtWebSockets -t qt6Mqtt
  rem ...future WASM supported modules -t qtThreading -t qtConcurrent -t qtEmscriptenAsyncify -t qtSockets
  set _QTW_CONFIG_OPTIONS=-platform wasm-emscripten
  set _QTW_CONFIG_OPTIONS=%_QTW_CONFIG_OPTIONS% -qt-freetype -qt-harfbuzz -qt-libpng -qt-libjpeg
  set _QTW_CONFIG_OPTIONS=%_QTW_CONFIG_OPTIONS% -qt-zlib -qt-pcre
  rem set _QTW_CONFIG_OPTIONS=%_QTW_CONFIG_OPTIONS% -sql-mysql
  set _QTW_CONFIG_OPTIONS=%_QTW_CONFIG_OPTIONS% -no-sql-odbc
  set _QTW_CONFIG_OPTIONS=%_QTW_CONFIG_OPTIONS% --trace=ctf
  set _QTW_CONFIG_OPTIONS=%_QTW_CONFIG_OPTIONS% -skip qtwebengine -skip qtwebview
  set _QTW_CONFIG_OPTIONS=%_QTW_CONFIG_OPTIONS% -no-warnings-are-errors -nomake examples -nomake tests
  set _QTW_CONFIG_OPTIONS=%_QTW_CONFIG_OPTIONS% -- -DLLVM_INSTALL_DIR="%_QTW_LLVM_INSTALL_DIR%"
  set _QTW_CONFIG_OPTIONS=%_QTW_CONFIG_OPTIONS% -DFEATURE_clangcpp=OFF
  rem set _QTW_CONFIG_OPTIONS=%_QTW_CONFIG_OPTIONS% -DFEATURE_clang=ON
  rem set _QTW_CONFIG_OPTIONS=%_QTW_CONFIG_OPTIONS% -DClang_DIR="%_QTW_LLVM_INSTALL_DIR%"

  echo.>>"%_QTW_LOGFILE%"
  echo DEBUG INFO: CONFIGURATION SETTINGS >>"%_QTW_LOGFILE%"
  set QT_ >>"%_QTW_LOGFILE%"
  set QTW_ >>"%_QTW_LOGFILE%"
  rem set _QT_ >>"%_QTW_LOGFILE%"
  set _QTW_ >>"%_QTW_LOGFILE%"
  path >>"%_QTW_LOGFILE%"
  echo.>>"%_QTW_LOGFILE%"
  
  echo "%QTW_BUILD_DIR%\configure.bat" -qt-host-path "%QTW_HOST_DIR%" -prefix "%_QTW_PREFIX_DIR%" %_QTW_CONFIG_OPTIONS% --log-level=VERBOSE %_QTW_TEE_LOG%
  call "%QTW_BUILD_DIR%\configure.bat" -qt-host-path "%QTW_HOST_DIR%" -prefix "%_QTW_PREFIX_DIR%" %_QTW_CONFIG_OPTIONS% --log-level=VERBOSE >>"%_QTW_LOGFILE%" 2>&1
  
:qtw_configure_test
  echo.
  echo QT-WASM %QTW_VERSION% - testing CONFIGURE: %_QTW_TEE_LOG%
  if not exist "%QTW_BUILD_DIR%\qtbase\lib\cmake\Qt6Core\Qt6CoreConfig.cmake" echo missing Qt6CoreConfig.cmake %_QTW_TEE_LOG% &goto :qtw_configure_retry
  if not exist "%QTW_BUILD_DIR%\qtbase\lib\cmake\Qt6Gui\Qt6GuiConfig.cmake" echo missing Qt6GuiConfig.cmake %_QTW_TEE_LOG% &goto :qtw_configure_retry
  if not exist "%QTW_BUILD_DIR%\qtbase\lib\cmake\Qt6Network\Qt6NetworkConfig.cmake" echo missing Qt6NetworkConfig.cmake %_QTW_TEE_LOG% &goto :qtw_configure_retry
  if not exist "%QTW_BUILD_DIR%\qtbase\lib\cmake\Qt6Widgets\Qt6WidgetsConfig.cmake" echo missing Qt6WidgetsConfig.cmake %_QTW_TEE_LOG% &goto :qtw_configure_retry
  if not exist "%QTW_BUILD_DIR%\qtbase\lib\cmake\Qt6Qml\Qt6QmlConfig.cmake" echo missing Qt6QmlConfig.cmake %_QTW_TEE_LOG% &goto :qtw_configure_retry
  if not exist "%QTW_BUILD_DIR%\qtbase\lib\cmake\Qt6Quick\Qt6QuickConfig.cmake" echo missing Qt6QuickConfig.cmake %_QTW_TEE_LOG% &goto :qtw_configure_retry
  if not exist "%QTW_BUILD_DIR%\qtbase\lib\cmake\Qt6QuickControls2\Qt6QuickControls2Config.cmake" echo missing Qt6QuickControls2Config.cmake %_QTW_TEE_LOG% &goto :qtw_configure_retry
  if not exist "%QTW_BUILD_DIR%\qtbase\lib\cmake\Qt6QuickLayouts\Qt6QuickLayoutsConfig.cmake" echo missing Qt6QuickLayoutsConfig.cmake %_QTW_TEE_LOG% &goto :qtw_configure_retry
  if not exist "%QTW_BUILD_DIR%\qtbase\lib\cmake\Qt6Core5Compat\Qt6Core5CompatConfig.cmake" echo missing Qt6Core5CompatConfig.cmake %_QTW_TEE_LOG% &goto :qtw_configure_retry
  if not exist "%QTW_BUILD_DIR%\qtbase\lib\cmake\Qt6OpenGL\Qt6OpenGLConfig.cmake" echo missing Qt6OpenGLConfig.cmake %_QTW_TEE_LOG% &goto :qtw_configure_retry
  if not exist "%QTW_BUILD_DIR%\qtbase\lib\cmake\Qt6Svg\Qt6SvgConfig.cmake" echo missing Qt6SvgConfig.cmake %_QTW_TEE_LOG% &goto :qtw_configure_retry
  if not exist "%QTW_BUILD_DIR%\qtbase\lib\cmake\Qt6WebSockets\Qt6WebSocketsConfig.cmake" echo missing Qt6WebSocketsConfig.cmake %_QTW_TEE_LOG% &goto :qtw_configure_retry
  if not exist "%QTW_BUILD_DIR%\qtbase\lib\cmake\Qt6Mqtt\Qt6MqttConfig.cmake" echo missing Qt6MqttConfig.cmake %_QTW_TEE_LOG% &goto :qtw_configure_retry
  rem if not exist "%QTW_BUILD_DIR%\qtbase\lib\cmake\Qt6ImageFormats\Qt6ImageFormatsConfig.cmake" echo missing Qt6ImageFormatsConfig.cmake %_QTW_TEE_LOG% &goto :qtw_configure_retry
  rem if not exist "%QT_BUILD_DIR%\qtbase\lib\cmake\Qt6DBus\Qt6DBusConfig.cmake" echo missing Qt6DBusConfig.cmake %_QTW_TEE_LOG% &goto :qtw_configure_retry
  goto :qtw_configure_done
:qtw_configure_retry
  set /A _QTW_TRY=%_QTW_TRY%+1
  if %_QTW_TRY% gtr %_QTW_TRIES% echo QT-WASM %QTW_VERSION% CONFIGURE incomplete %_QTW_TEE_LOG% &goto :qtw_configure_done
  goto :qtw_configure_do
:qtw_configure_done


rem (10) *** build QT-WASM ***
:qtw_build
set _QTW_TRIES=1
set _QTW_TRY=0
goto :qtw_build_test
:qtw_build_do
  echo.
  echo ******************************************************************************** %_QTW_TEE_LOG%
  echo QT-BUILD WASM %QTW_VERSION% (TRY %_QTW_TRY%) %_QTW_TEE_LOG%
  echo ******************************************************************************** %_QTW_TEE_LOG%
  cd /d "%QTW_BUILD_DIR%"
  :: https://doc.qt.io/qt-6/wasm.html#supported-qt-modules
  rem set _QTW_BUILD_OPTIONS=-t qtbase -t qtdeclarative
  rem set _QTW_BUILD_OPTIONS=%_QTW_BUILD_OPTIONS% -t qtCore -t qtGui -t qtNetwork -t qtWidgets -t qtQml -t qtQuick-t qtQuickControls -t qtQuickLayouts -t qt5CoreCompatibilityAPIs -t qtImageFormats -t qtOpenGL -t qtSVG -t qtWebSockets -t qt6Mqtt
  rem future WASM supported modules:
  rem set _QTW_BUILD_OPTIONS=%_QTW_BUILD_OPTIONS% -t qtThreading -t qtConcurrent -t qtEmscriptenAsyncify -t qtSockets
  ::
  rem set _QTW_BUILD_OPTIONS=-t qtbase -t qtdeclarative -t qtSVG -t qtWebSockets -t qt6Mqtt
  set _QTW_BUILD_OPTIONS=
  echo cmake --build . %_QTW_BUILD_OPTIONS% %_QTW_TEE_LOG%
  call cmake --build . %_QTW_BUILD_OPTIONS% >>"%_QTW_LOGFILE%" 2>&1
  
:qtw_build_test
  echo.
  echo QT-WASM %QTW_VERSION% - testing BUILD: %_QTW_TEE_LOG%
  if not exist "%QTW_BUILD_DIR%\qtbase\bin\qtloader.js" echo missing qtloader.js %_QTW_TEE_LOG% &goto :qtw_build_retry
  if not exist "%QTW_BUILD_DIR%\qtbase\lib\libQt6Core.a" echo missing libQt6Core.a %_QTW_TEE_LOG% &goto :qtw_build_retry
  if not exist "%QTW_BUILD_DIR%\qtbase\lib\libQt6QuickWidgets.a" echo missing libQt6QuickWidgets.a %_QTW_TEE_LOG% &goto :qtw_build_retry
  if not exist "%QTW_BUILD_DIR%\plugins\imageformats\libqtga.a" echo missing libqtga.a %_QTW_TEE_LOG% &goto :qtw_build_retry
  goto :qtw_build_done
:qtw_build_retry
  set /A _QTW_TRY=%_QTW_TRY%+1
  if %_QTW_TRY% gtr %_QTW_TRIES% echo QT-WASM %QTW_VERSION% BUILD incomplete %_QTW_TEE_LOG% &goto :qtw_build_done
  goto :qtw_build_do
:qtw_build_done


rem (11) *** install QT-WASM ***
:qtw_install
cd /d "%QTW_BUILD_DIR%"
echo cmake --install . %_QTW_TEE_LOG%
call cmake --install . >>"%_QTW_LOGFILE%" 2>&1

:qtw_setup
if "%QTW_BIN_DIR%" equ "" echo QT-WASM %QTW_VERSION% INSTALL incomplete %_QTW_TEE_LOG% &goto :qtw_exit
if not exist "%QTW_BIN_DIR%" echo QT-WASM %QTW_VERSION% INSTALL incomplete %_QTW_TEE_LOG% &goto :qtw_exit
if not exist "%QTW_BIN_DIR%\bin" echo QT-WASM %QTW_VERSION% INSTALL incomplete %_QTW_TEE_LOG% &goto :qtw_exit
if not exist "%QTW_BIN_DIR%\bin\qmake.bat" echo QT-WASM %QTW_VERSION% INSTALL incomplete %_QTW_TEE_LOG% &goto :qtw_exit

rem make Qt-Wasm qmake and make available
set "path=%QTW_BIN_DIR%\bin;%path%"
call "%MAKER_DIR_SCRIPTS%\ensure_make.bat" %MAKER_MSG_VERBOSE%
echo.
echo.QT-WASM example:
rem see also https://bayernmuller.github.io/blog/240104-webassembly-qt/
echo.^>cd %QTW_EXAMPLES_DIR%\gui_localfiles
echo.^>qmake gui_localfiles.pro
echo.^>make
echo. now run the generated gui_localfiles.wasm and the test html page gui_localfiles.html via local webserver and browser
echo. 1) via emscripten emrun tool:
echo.^>emrun --browser chrome gui_localfiles.html
echo. tip: emrun --list_browser
rem echo. 2) via python webserver:
rem echo.%QTW_EXAMPLES_DIR%\gui_localfiles^>python -m http.server 8000
rem echo.%QTW_EXAMPLES_DIR%\gui_localfiles^>explorer "http://localhost:8000/gui_localfiles.html" (open in webwrowser)
echo.
goto :qtw_install_done

rem todo: try to test qt-wasm qmake
set "_QTW_TEST_TOOL=qmake"
call "%~dp0\core\generic_validate.bat" "_QTWASM" "%_QTW_TEST_TOOL% --version" "for /f ""tokens=1,2,3,4,* delims= "" %%%%i in ('call %_QTW_TEST_TOOL% --version') do if /I %%%%j EQU Qt if /I %%%%k EQU version echo %%%%l" %QTW_VERSION% %MAKER_MSG_VERBOSE% 1>nul 2>nul
if %ERRORLEVEL% NEQ 0 set "path=%QTW_BIN_DIR%\bin;%path%"
set _QTW_TEST_TOOL=
call "%MAKER_ENV_CORE%\clear_temp_envs.bat" "_QTWASM" 1>nul 2>nul
call "%~dp0\validate_qt-wasm.bat" %QTW_VERSION% %MAKER_MSG_VERBOSE%
exit /b %ERRORLEVEL%

:qtw_install_done
:qtw_exit
call "%MAKER_ENV_CORE%\stop_watch.bat" "%_QTW_BUILD_DATETIME_START%"
set "_QTW_BUILD_DATE_STOP=%_DATE_%"
set "_QTW_BUILD_TIME_STOP=%_TIME_UI%"
set "_QTW_BUILD_DURATION=%_DIFFT_DUR_SS%"
echo.>>"%_QTW_LOGFILE%"
echo.%_QTW_BUILD_DATE_START% %_QTW_BUILD_TIME_START%...%_QTW_BUILD_TIME_STOP% ^(duration %_QTW_BUILD_DURATION% sec^)>>"%_QTW_LOGFILE%"
echo.
echo.BUILD-LOGFILE : "%_QTW_LOGFILE%"
echo.BUILD-START   : %_QTW_BUILD_DATE_START% %_QTW_BUILD_TIME_START%
echo.BUILD-STOP    : %_QTW_BUILD_DATE_STOP% %_QTW_BUILD_TIME_STOP%
echo.BUILD-DURATION: %_QTW_BUILD_DURATION% sec
echo.
rem cd /d "%QT_DIR%"
rem cd /d "%_QTW_START_DIR%"
cd /d "%QTW_EXAMPLES_DIR%"
call "%MAKER_ENV_CORE%\clear_temp_envs.bat" "_QTW_" 1>nul 2>nul
