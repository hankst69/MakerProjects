@rem https://doc.qt.io/qt-6/getting-sources-from-git.html
@rem https://doc.qt.io/qt-6/configure-options.html
@rem https://doc.qt.io/qt-6/build-sources.html
@rem https://doc.qt.io/qt-6/windows-building.html
@rem https://code.qt.io/cgit
@echo off
if /I "%~1" equ "-?" goto :_QT_USAGE
if /I "%~1" equ "-h" goto :_QT_USAGE
if /I "%~1" equ "--help" goto :_QT_USAGE
goto :_QT_START

:_QT_USAGE
echo USAGE:
echo %~n0 [version] [--use_gcc] [--use_llvm20_patch] [-?^|-h^|--help]
goto :EOF

:_QT_START
call "%~dp0\maker_env.bat" %*

call "%MAKER_SCRIPTS%\clear_temp_envs.bat" "_QT_" 1>nul 2>nul
set "_QT_START_DIR=%cd%"
set "_QT_VERSION=%MAKER_ENV_VERSION%"
set "_QT_BUILD_TYPE=%MAKER_ENV_BUILDTYPE%"
set "_QT_TGT_ARCH=%MAKER_ENV_ARCHITECTURE%"
set "_QT_REBUILD=%MAKER_ENV_REBUILD%"

set _QT_USE_LLVM20_PATCH=
set _QT_USE_GCC=
if /I "%MAKER_ENV_UNKNOWN_SWITCH_1%" equ "--use_llvm20_patch" set _QT_USE_LLVM20_PATCH=true
if /I "%MAKER_ENV_UNKNOWN_SWITCH_2%" equ "--use_llvm20_patch" set _QT_USE_LLVM20_PATCH=true
if /I "%MAKER_ENV_UNKNOWN_SWITCH_1%" equ "--use_gcc" set _QT_USE_GCC=true
if /I "%MAKER_ENV_UNKNOWN_SWITCH_2%" equ "--use_gcc" set _QT_USE_GCC=true

rem apply defaults 1
if "%_QT_TGT_ARCH%" equ "" set "_QT_TGT_ARCH=x64"
if "%_QT_VERSION%" equ "" set _QT_VERSION=6.8.3
set "_QT_VERSION_WITH_LLVM_FIX=6.9.0"
set "_QT_BUILD_TYPE=release"
set "_QT_MSVS_VERSION=GEQ2019"
set "_QT_CMAKE_VERSION=GEQ3.22"
rem
rem CLONE options
rem set "_QT_CLONE_OPTIONS=--silent --init_submodules"
set "_QT_CLONE_OPTIONS=--silent --init_submodules --clone_submodules"
rem
rem MSVS BUILD options
set _QT_BUILD_OPTIONS_MSVS=
rem set "_QT_BUILD_OPTIONS_MSVS=%_QT_BUILD_OPTIONS_MSVS% -qt-freetype -qt-harfbuzz -qt-libpng -qt-libjpeg -qt-zlib -qt-pcre"
rem set "_QT_BUILD_OPTIONS_MSVS=%_QT_BUILD_OPTIONS_MSVS% --trace=ctf"
set "_QT_BUILD_OPTIONS_MSVS=%_QT_BUILD_OPTIONS_MSVS% -skip qtwebengine"
  rem CMake Error at qtbase/cmake/QtWindowsHelpers.cmake:10 (message):
  rem   Qt requires at least Visual Studio 2022 (MSVC 1930 or newer), you're
  rem   building against version 1929.  You can turn off this version check by
  rem   setting QT_NO_MSVC_MIN_VERSION_CHECK to ON.
set "_QT_BUILD_OPTIONS_MSVS=%_QT_BUILD_OPTIONS_MSVS% -- -DQT_NO_MSVC_MIN_VERSION_CHECK=ON --log-level=VERBOSE"
rem
rem MingGW-GCC BUILD options
set "_QT_BUILD_OPTIONS_GCC=-platform win32-g++"
set "_QT_BUILD_OPTIONS_GCC=%_QT_BUILD_OPTIONS_GCC% -qt-freetype -qt-harfbuzz -qt-libpng -qt-libjpeg"
set "_QT_BUILD_OPTIONS_GCC=%_QT_BUILD_OPTIONS_GCC% -qt-zlib -qt-pcre"
rem set "_QT_BUILD_OPTIONS_GCC=%_QT_BUILD_OPTIONS_GCC% --freetype=qt --harfbuzz=qt --libpng=qt --libjpeg=qt --zlib=qt --pcre=qt --sqlite=qt"
rem set "_QT_BUILD_OPTIONS_GCC=%_QT_BUILD_OPTIONS_GCC% --sqlite=qt"
set "_QT_BUILD_OPTIONS_GCC=%_QT_BUILD_OPTIONS_GCC% -sql-mysql -no-sql-odbc"
rem set "_QT_BUILD_OPTIONS_GCC=%_QT_BUILD_OPTIONS_GCC% -skip qtsql"
set "_QT_BUILD_OPTIONS_GCC=%_QT_BUILD_OPTIONS_GCC% --trace=ctf"
rem set "_QT_BUILD_OPTIONS_GCC=%_QT_BUILD_OPTIONS_GCC% -cmake-generator ""MinGW Makefiles"""
set "_QT_BUILD_OPTIONS_GCC=%_QT_BUILD_OPTIONS_GCC% -- -DMINGW=1 --log-level=VERBOSE"
rem
rem BUILD options
set "_QT_BUILD_OPTIONS=-nomake examples -nomake tests"
if /I "%_QT_USE_GCC%" neq "true" set "_QT_BUILD_OPTIONS=%_QT_BUILD_OPTIONS% %_QT_BUILD_OPTIONS_MSVS%"
if /I "%_QT_USE_GCC%" equ "true" set "_QT_BUILD_OPTIONS=%_QT_BUILD_OPTIONS% %_QT_BUILD_OPTIONS_GCC%"
if /I "%_QT_BUILD_TYPE%" neq "release" set "_QT_BUILD_OPTIONS=%_QT_BUILD_OPTIONS% -force-debug-info -separate-debug-info"
rem apply defaults 3
set _QT_COMPILER=msvs
if /I "%_QT_USE_GCC%" equ "true" set _QT_COMPILER=gcc
call "%MAKER_SCRIPTS%\compare_versions.bat" "%_QT_VERSION%" "LSS" "%_QT_VERSION_WITH_LLVM_FIX%" 1>nul 2>nul
if %ERRORLEVEL% equ 0 set _QT_USE_LLVM20_PATCH=true


rem if we build QT 5.12 this means that we like to meet the ChimaeraCUT3.6SDK Qt version from C:\Chimaera\CUT.SDK-3.6.0\bin\Release
if "%_QT_VERSION%" equ "5.12" set _QT_CMAKE_VERSION=GEQ3.20
if "%_QT_VERSION%" equ "5.12" set _QT_MSVS_VERSION=2019

rem welcome
echo BUILDING QT %_QT_VERSION% %_QT_COMPILER%

rem (1) *** cloning QT sources ***
call "%MAKER_BUILD%\clone_qt.bat" %_QT_VERSION% %MAKER_ENV_VERBOSE% %_QT_CLONE_OPTIONS%
cd /d "%_QT_START_DIR%"
rem defines: QT_DIR
rem defines: QT_SOURCES_DIR
if "%QT_DIR%" EQU "" (echo cloning Qt %_QT_VERSION% failed &goto :qt_exit)
if "%QT_SOURCES_DIR%" EQU "" (echo cloning Qt %_QT_VERSION% failed &goto :qt_exit)
if not exist "%QT_DIR%" (echo cloning Qt %_QT_VERSION% failed &goto :qt_exit)
if not exist "%QT_SOURCES_DIR%" (echo cloning Qt %_QT_VERSION% failed &goto :qt_exit)

rem show what we have so far
if "%MAKER_ENV_VERBOSE%" neq "" set QT_

set "_QT_BUILD_DIR=%QT_DIR%\qt_build%_QT_VERSION%"
set "_QT_BIN_DIR=%QT_DIR%\qt%_QT_VERSION%"
if /I "%_QT_USE_GCC%" equ "true" set "_QT_BUILD_DIR=%QT_DIR%\qt_build%_QT_VERSION%-gcc"
if /I "%_QT_USE_GCC%" equ "true" set "_QT_BIN_DIR=%QT_DIR%\qt%_QT_VERSION%-gcc"

set "_QT_LOGFILE=%QT_DIR%\qt_build_%_QT_VERSION%_%_QT_COMPILER%_configure.log"


rem (2) *** specify LLVM version ***
rem (2.1) match LLVM version to target QT version 
rem       todo: find the correct LLVM version dependency for qt 6.8.2
set _QT_LLVM_VER=14
call "%MAKER_SCRIPTS%\compare_versions.bat" "%_QT_VERSION%" 6.7 GEQ --no_errors
if %ERRORLEVEL% equ 0 set _QT_LLVM_VER=18
call "%MAKER_SCRIPTS%\compare_versions.bat" "%_QT_VERSION%" 7.0 GEQ --no_errors
if %ERRORLEVEL% equ 0 set _QT_LLVM_VER=20
rem (2.2) switch to (latest) LLVM 20 if desired (but might require a patch for QT to build)
rem       todo: clarify, is this qt patch for LLVM20 is still valid or maybe not neccesary anymore
if "%_QT_LLVM_VER%" neq "20" if "%_QT_USE_LLVM20_PATCH%" neq "" if exist "%MAKER_TOOLS%\packages\qt663_qttools-llvm20-patch.7z" (
  pushd "%QT_SOURCES_DIR%\qttools"
  call 7z x -y "%MAKER_TOOLS%\packages\qt663_qttools-llvm20-patch.7z" 1>NUL
  popd 
  set _QT_LLVM_VER=20
)
set _QT_LLVM_VER_VERIFY=%_QT_LLVM_VER%
rem (2.3) switch to latest LLVM version (no version nr specified where possible when we shall use LLVM 20 or LLVM 18)
rem       todo: clarify if this is valid for QT6.8.3 without the LLVM20 patch
rem       todo: somehow handle the case when the latest LLVM is much newer than current 20 and then gets incompatible with QT build
if "%_QT_LLVM_VER%" equ "20" set _QT_LLVM_VER=&set _QT_LLVM_VER_VERIFY=20
if "%_QT_LLVM_VER%" equ "18" set _QT_LLVM_VER=&set _QT_LLVM_VER_VERIFY=20


rem *** verbose listing of variables ***
if "%MAKER_ENV_VERBOSE%" neq "" set _QT_


rem (4) *** cleaning QT build if demanded ***
if "%_QT_REBUILD%" neq "" (
  echo preparing rebuild...
  rmdir /s /q "%_QT_BIN_DIR%" 1>nul 2>nul
  rmdir /s /q "%_QT_BUILD_DIR%" 1>nul 2>nul
)
if not exist "%_QT_BIN_DIR%" mkdir "%_QT_BIN_DIR%"
if not exist "%_QT_BUILD_DIR%" mkdir "%_QT_BUILD_DIR%"


rem (5) *** testing for existing QT build ***
set "_QT_TEST_EXE_UIC=%_QT_BIN_DIR%\bin\uic.exe"
set "_QT_TEST_DLL_WEBSOKETS=%_QT_BIN_DIR%\bin\Qt6WebSockets.dll"
set "_QT_TEST_LIB_MQTT=%_QT_BIN_DIR%\lib\Qt6Mqtt.lib"
if /I "%_QT_USE_GCC%" equ "true" set "_QT_TEST_LIB_MQTT=%_QT_BIN_DIR%\lib\libQt6Mqtt.a"

if not exist "%_QT_TEST_LIB_MQTT%" goto :qt_rebuild
if not exist "%_QT_TEST_DLL_WEBSOKETS%" goto :qt_rebuild
rem if not exist "%_QT_BIN_DIR%\bin\lupdate.exe" goto :qt_rebuild
if not exist "%_QT_TEST_EXE_UIC%" goto :qt_rebuild
rem if not exist "%_QT_BIN_DIR%\lib\cmake\Qt6Mqtt\Qt6MqttConfig.cmake" goto :qt_rebuild
call which Qt6WebSockets.dll 1>nul 2>nul
if %ERRORLEVEL% EQU 0 echo QT %_QT_VERSION% %_QT_COMPILER% already available&goto :qt_install_done
set "PATH=%PATH%;%_QT_BIN_DIR%\bin"
call which Qt6WebSockets.dll 1>nul 2>nul
if %ERRORLEVEL% EQU 0 echo QT %_QT_VERSION% %_QT_COMPILER% already available&goto :qt_install_done
echo error: QT %_QT_VERSION% %_QT_COMPILER% seems to be prebuild but is not working
echo try rebuilding via '%~n0 --rebuild %_QT_VERSION%'
goto :qt_exit


:qt_rebuild
rem (6) *** ensuring prerequisites ***
rem
rem https://doc.qt.io/qt-6/windows-building.html
rem building Qt (libs and tools) requires:
rem
rem * mandatory: CMake 3.22 or newer
rem * mandatory: Python 3
rem * mandatory: MSVC2019 or MSVC2022 or Mingw-w64 13.1
rem              whatever compiler is used it has to be set up to create "amd64" targets
rem              for Mingw this means to add "...\mingw..._64\bin" to the PATH environment
rem * optional:  Ninja
rem * optional:  LLVM/Clang (for QDoc)  
rem              https://doc.qt.io/qt-6/qdoc-guide-clang.html
rem              https://github.com/qt-creator/qt-creator/blob/master/README.md#getting-llvmclang-for-the-clang-code-model
rem * optional:  Perl (for opus optimization)
rem * optional:  node.js 14 or newer (for QtWebEngine, QtPdf)
rem * optional:  gperf (for QtWebEngine, QtPdf)
rem * optional:  bison (for QtWebEngine, QtPdf) see https://gnuwin32.sourceforge.net/packages/bison.htm  https://github.com/akimd/bison 
rem * optional:  flex  (for QtWebEngine, QtPdf) 
rem * optional:  gRPC and Protobuf packages (for QtGRPC and QtProtobuf) 
rem              -> install gRPC and Protobuf via vcpkg: https://doc.qt.io/qt-6/qtprotobuf-installation-windows-vcpkg.html
rem                 ".\vcpkg.exe install grpc:x64-windows"
rem                 ".\vcpkg.exe install protobuf protobuf:x64-windows"
rem              -> build gRPC from source:     https://github.com/grpc/grpc/blob/v1.60.0/BUILDING.md#windows
rem              -> build Protobuf from source: https://github.com/protocolbuffers/protobuf/blob/main/cmake/README.md#windows-builds
rem 
rem call "%QT_SOURCES_DIR%\configure.bat" --help
rem 
echo.
echo rebuilding Qt %_QT_VERSION% %_QT_COMPILER% from sources
echo see https://doc.qt.io/qt-6/windows-building.html
echo.
echo *** THIS REQUIRES VisualStudio 2019 or 2022 or Mingw
echo *** THIS REQUIRES Python 3
echo *** THIS REQUIRES Cmake 3.22 or newer
echo *** OTPIONAL: Ninja
echo *** OTPIONAL: Perl
echo *** OTPIONAL: LLVM/Clang
echo *** OTPIONAL: Node.js
echo *** OTPIONAL: gRPC
echo *** OTPIONAL: Protobuf
echo *** OPTIONAL: gperf, bison, flex (for QtWebEngine)
echo.
rem ensure msvs version and amd64 target architecture or MinGW gcc
if /I "%_QT_USE_GCC%" neq "true" call "%MAKER_BUILD%\ensure_msvs.bat" %_QT_MSVS_VERSION% amd64 %MAKER_ENV_VERBOSE%
if %ERRORLEVEL% NEQ 0 if /I "%_QT_USE_GCC%" neq "true" (
  goto :qt_exit
)
if /I "%_QT_USE_GCC%" equ "true" call "%MAKER_BUILD%\ensure_gcc.bat" %MAKER_ENV_VERBOSE%
if %ERRORLEVEL% NEQ 0 if /I "%_QT_USE_GCC%" equ "true" (
  goto :qt_exit
)
rem if /I "%_QT_USE_GCC%" neq "true" call "%MAKER_BUILD%\validate_msvs.bat" %_QT_MSVS_VERSION% amd64 %MAKER_ENV_VERBOSE%
rem if /I "%_QT_USE_GCC%" equ "true" call "%MAKER_BUILD%\validate_gcc.bat" %MAKER_ENV_VERBOSE%
rem validate cmake
call "%MAKER_BUILD%\validate_cmake.bat" %_QT_CMAKE_VERSION% %MAKER_ENV_VERBOSE%
if %ERRORLEVEL% NEQ 0 (
  goto :qt_exit
)
rem validate ninja
call "%MAKER_BUILD%\validate_ninja.bat" --no_errors %MAKER_ENV_VERBOSE%
if %ERRORLEVEL% NEQ 0 (
  echo warning: NINJA is not available
  rem goto :qt_exit
)
rem validate llvm (due error: set LLVM_INSTALL_DIR + need to set the FEATURE_clang and FEATURE_clangcpp CMake variable to ON to re-evaluate this checks)
call "%MAKER_BUILD%\validate_llvm.bat" %_QT_LLVM_VER_VERIFY% --no_errors %MAKER_ENV_VERBOSE%
if %ERRORLEVEL% NEQ 0 call "%MAKER_BUILD%\build_llvm.bat" %_QT_LLVM_VER% --no_errors %MAKER_ENV_VERBOSE%
if %ERRORLEVEL% NEQ 0 call "%MAKER_BUILD%\validate_llvm.bat" %_QT_LLVM_VER_VERIFY% --no_errors %MAKER_ENV_VERBOSE%
if %ERRORLEVEL% NEQ 0 (
  echo warning: LLVM CLANG is not available
  goto :qt_exit
)
rem validate perl (for opus optimization) (also see QNX/gperf see https://github.com/gperftools/gperftools/issues/1429)
call "%MAKER_BUILD%\validate_perl.bat" --no_errors %MAKER_ENV_VERBOSE%
if %ERRORLEVEL% NEQ 0 (
  echo warning: PERL is not available
  rem goto :qt_exit
)
rem validate python
call "%MAKER_BUILD%\validate_python.bat" GEQ3 "%MSVS_TARGET_ARCHITECTURE%"
if %ERRORLEVEL% NEQ 0 (
  if /I "%PYTHON_ARCHITECTURE%" neq "%MSVS_TARGET_ARCHITECTURE%" (
    echo error: python architecture '%PYTHON_ARCHITECTURE%' does not match msvs target architecture '%MSVS_TARGET_ARCHITECTURE%'
  )
  goto :qt_exit
)

rem (7) *** setup QT dependencies ***
rem validate node.js 
call "%MAKER_BUILD%\ensure_nodejs.bat" GEQ14 --no_errors
if %ERRORLEVEL% NEQ 0 (
  echo warning: NODE.JS is not available
  goto :qt_exit
)
rem ensure gperf (for QtWebEngine see https://stackoverflow.com/questions/73498046/building-qt5-from-source-qtwebenginecore-module-will-not-be-built-tool-gperf-i)
rem WARNING: QtWebEngine won't be built. Tool gperf is required.
call "%MAKER_BUILD%\ensure_gperf.bat" --no_errors
if %ERRORLEVEL% NEQ 0 (
  echo warning: GPERF is not available
  rem goto :qt_exit
)
rem ensure bison
rem WARNING: QtWebEngine won't be built. Tool bison is required.
call "%MAKER_BUILD%\ensure_bison.bat" --no_errors
if %ERRORLEVEL% NEQ 0 (
  echo warning: BISON is not available
  rem goto :qt_exit
)
rem esnure flex
rem Support check for QtWebEngine failed: Tool flex is required.
call "%MAKER_BUILD%\ensure_flex.bat" --no_errors
if %ERRORLEVEL% NEQ 0 (
  echo warning: FLEX is not available
  rem goto :qt_exit
)
rem setup gRPC
rem call "%MAKER_BUILD%\build_grpc.bat" x64-windows
  rem pushd "%QT_DIR%"
  rem call vcpkg install grpc:x64-windows
  rem popd
rem setup Protobuf
rem call "%MAKER_BUILD%\build_protobuf.bat" x64-windows
  rem pushd "%QT_DIR%"
  rem call vcpkg install protobuf protobuf:x64-windows
  rem popd

rem setup Python packages
rem clarify: create a dedicated  python venv for configuring/building ?
call python -m pip install --upgrade pip
call python -m pip install html5lib
rem call python -m pip wheel html5lib


rem (8) *** configure QT build ***
rem but it set Qt6_FOUND to FALSE so package "Qt6" is considered to be NOT
rem   FOUND.  Reason given by package:
rem   Failed to find required Qt component "Mqtt".
rem   Expected Config file at
rem   "C:/GIT/Maker/tools/Qt/qt6.6.3/lib/cmake/Qt6Mqtt/Qt6MqttConfig.cmake" does
rem   NOT exist
rem   Configuring with --debug-find-pkg=Qt6Mqtt might reveal details why the
rem   package was not found.
:qt_configure_test
rem if not exist "%_QT_BIN_DIR%\lib\cmake\Qt6Mqtt\Qt6MqttConfig.cmake" echo QT-CONFIGURE %_QT_VERSION% not yet done or incomplete &goto :qt_configure
if not exist "%_QT_BUILD_DIR%\qtmqtt\src\mqtt\cmake_install.cmake" echo QT-CONFIGURE %_QT_VERSION% not yet done or incomplete &goto :qt_configure
if exist "%_QT_BUILD_DIR%\qtbase\bin\qt-cmake.bat" echo QT-CONFIGURE %_QT_VERSION% already done &goto :qt_configure_done
:qt_configure
  echo QT-CONFIGURE %_QT_VERSION%
  if not exist "%_QT_BUILD_DIR%" mkdir "%_QT_BUILD_DIR%"
  cd /d "%_QT_BUILD_DIR%"
  echo. >"%_QT_LOGFILE%"
  call "%QT_SOURCES_DIR%\configure.bat" --help >>"%_QT_LOGFILE%"
  echo. >>"%_QT_LOGFILE%"
  call "%QT_SOURCES_DIR%\configure.bat" -list-features 2>>"%_QT_LOGFILE%"
  echo. >>"%_QT_LOGFILE%"
  echo. "%QT_SOURCES_DIR%\configure.bat" -prefix "%_QT_BIN_DIR%" -%_QT_BUILD_TYPE% %_QT_BUILD_OPTIONS% >>"%_QT_LOGFILE%"
  set _QT_CONFIGURE_RETRIES=0
  :qt_configure_do
  echo. >>"%_QT_LOGFILE%"
  echo QT-CONFIGURE TRY %_QT_CONFIGURE_RETRIES% >>"%_QT_LOGFILE%"
  echo. >>"%_QT_LOGFILE%"
  cd /d "%_QT_BUILD_DIR%"
  call "%QT_SOURCES_DIR%\configure.bat" -prefix "%_QT_BIN_DIR%" -%_QT_BUILD_TYPE% %_QT_BUILD_OPTIONS% >>"%_QT_LOGFILE%"
  rem validate QtMqtt configuration done
  if exist "%_QT_BUILD_DIR%\qtmqtt\src\mqtt\cmake_install.cmake" goto :qt_configure_done
  if "%_QT_CONFIGURE_RETRIES%" equ "1" set _QT_CONFIGURE_RETRIES=2
  if "%_QT_CONFIGURE_RETRIES%" equ "0" set _QT_CONFIGURE_RETRIES=1
  if "%_QT_CONFIGURE_RETRIES%" equ ""  set _QT_CONFIGURE_RETRIES=1
  if "%_QT_CONFIGURE_RETRIES%" equ "2" echo QT-CONFIGURE incomplete after %_QT_CONFIGURE_RETRIES% tries & goto :qt_configure_done
  goto :qt_configure_do
:qt_configure_done

rem (9-1) *** perform QT Basic build ***
:qt_build_test
set _QT_BUILD_RETRIES=1
if not exist "%_QT_BIN_DIR%\lib\cmake\Qt6Mqtt\Qt6MqttConfig.cmake" echo QT-BUILD %_QT_VERSION% not yet done or incomplete &goto :qt_build
if exist "%_QT_BIN_DIR%\bin\designer.exe" echo QT-BUILD %_QT_VERSION% already done &goto :qt_build_done
:qt_build
  echo QT-BUILD %_QT_VERSION%
  if not exist "%_QT_BUILD_DIR%" mkdir "%_QT_BUILD_DIR%"
  cd /d "%_QT_BUILD_DIR%"
  call cmake --build . --parallel 4
  rem validate build done
  if exist "%_QT_BIN_DIR%\lib\cmake\Qt6Mqtt\Qt6MqttConfig.cmake" goto :qt_build_done
  if "%_QT_BUILD_RETRIES%" equ "1" set _QT_BUILD_RETRIES=2
  if "%_QT_BUILD_RETRIES%" equ "0" set _QT_BUILD_RETRIES=1
  if "%_QT_BUILD_RETRIES%" equ ""  set _QT_BUILD_RETRIES=1
  if "%_QT_BUILD_RETRIES%" equ "2" echo QT-BUILD incomplete after %_QT_BUILD_RETRIES% tries & goto :qt_build_done
  goto :qt_build
:qt_build_done

rem (9-2) *** perform QT Modules build ***
:qt_modules_build_test
goto :qt_modules_build_done
if exist "%_QT_BIN_DIR%\lib\Qt6Mqtt.lib" echo QT-BUILD %_QT_VERSION% already done &goto :qt_modules_build_done
:qt_modules_build
  echo QT-BUILD %_QT_VERSION%
  if not exist "%_QT_BUILD_DIR%\qtmqtt" mkdir "%_QT_BUILD_DIR%\qtmqtt"
  cd /d "%_QT_BUILD_DIR%\qtmqtt"
  call cmake --build . --target qtmqtt
:qt_modules_build_done


rem (10) *** perform QT install ***
:qt_install
if not exist "%_QT_TEST_EXE_UIC%" goto :qt_install_do
if not exist "%_QT_TEST_DLL_WEBSOKETS%" goto :qt_install_do
if not exist "%_QT_TEST_LIB_MQTT%" goto :qt_install_do
goto :qt_install_test
:qt_install_do
  echo QT-INSTALL %_QT_VERSION%
  cd /d "%_QT_BUILD_DIR%"
  call cmake --install .
  cd /d "%_QT_BUILD_DIR%\qtmqtt"
  call cmake --install .
  if not exist "%_QT_BIN_DIR%\bin\Qt6WebSockets.dll" echo error: QT-INSTALL %_QT_VERSION% FAILED&goto :qt_install_done
:qt_install_test
call which uic.exe 1>nul 2>nul
if %ERRORLEVEL% NEQ 0 set "PATH=%_QT_BIN_DIR%\bin;%PATH%"
call which uic.exe 1>nul 2>nul
if %ERRORLEVEL% EQU 0 echo QT-INSTALL %_QT_VERSION% available &goto :qt_install_done
echo error: QT-INSTALL %_QT_VERSION% failed
goto :qt_exit


:qt_install_done
rem -- create shortcuts
set "QT_BIN_DIR=%_QT_BIN_DIR%"
set "QT_VERSION=%_QT_VERSION%"
set "QT_CMAKE=%_QT_BIN_DIR%\bin\qt-cmake.bat"
set "QT_LLVM_VER=%_QT_LLVM_VER%"
set "QT_TEST_LIB_MQTT=%_QT_TEST_LIB_MQTT%"
if "%MAKER_ENV_VERBOSE%" neq "" set QT_
rem echo @"%QT_SOURCES_DIR%\configure.bat" %%*>"%MAKER_BIN%\qtconfigure.bat"
rem echo @"%QT_SOURCES_DIR%\qtbase\configure.bat" %%*>"%MAKER_BIN%\qtconfigure.bat"
echo @start /D "%QT_BIN_DIR%\bin" /MAX /B designer.exe %%*>"%MAKER_BIN%\qtdesigner.bat"

rem (11) post configure QT
rem call "QT_BIN_DIR%/bin/qt-configure-module.bat"

:qt_exit
cd /d "%_QT_START_DIR%"
call "%MAKER_SCRIPTS%\clear_temp_envs.bat" "_QT_" 1>nul 2>nul
if not exist "%QT_TEST_LIB_MQTT%" echo QT-BUILD %QT_VERSION% incomplete &exit /b 1
"%MAKER_BUILD%\validate_qt.bat" "%QT_VERSION%" --no_warnings