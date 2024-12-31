@rem https://doc.qt.io/qt-6/getting-sources-from-git.html
@rem https://doc.qt.io/qt-6/configure-options.html
@rem https://doc.qt.io/qt-6/build-sources.html
@rem https://doc.qt.io/qt-6/windows-building.html
@rem https://code.qt.io/cgit
@echo off
set "_BQT_START_DIR=%cd%"

call "%~dp0\maker_env.bat" %*
rem if "%MAKER_ENV_VERBOSE%" neq "" echo on

set "_QT_VERSION=%MAKER_ENV_VERSION%"
set "_QT_BUILD_TYPE=%MAKER_ENV_BUILDTYPE%"
set "_QT_TGT_ARCH=%MAKER_ENV_ARCHITECTURE%"
set "_REBUILD=%MAKER_ENV_REBUILD%"
rem apply defaults
if "%_QT_TGT_ARCH%" equ "" set "_QT_TGT_ARCH=x64"
if "%_QT_VERSION%" equ "" set _QT_VERSION=6.6.3
set _QT_BUILD_TYPE=Release

rem (1) *** cloning QT sources ***
call "%MAKER_BUILD%\clone_qt.bat" %_QT_VERSION% %MAKER_ENV_VERBOSE% %MAKER_ENV_UNKNOWN_SWITCHES%
rem defines: _QT_DIR
rem defines: _QT_SOURCES_DIR
if "%_QT_DIR%" EQU "" (echo cloning Qt %_QT_VERSION% failed &goto :Exit)
if "%_QT_SOURCES_DIR%" EQU "" (echo cloning Qt %_QT_VERSION% failed &goto :Exit)
if not exist "%_QT_DIR%" (echo cloning Qt %_QT_VERSION% failed &goto :Exit)
if not exist "%_QT_SOURCES_DIR%" (echo cloning Qt %_QT_VERSION% failed &goto :Exit)

set "_QT_BUILD_DIR=%_QT_DIR%\qt_build%_QT_VERSION%"
set "_QT_BIN_DIR=%_QT_DIR%\qt%_QT_VERSION%"

rem (2) *** specify LLVM version ***
set _QT_LLVM_VER=14
call "%MAKER_SCRIPTS%\compare_versions.bat" "%_QT_VERSION%" 6.7 GEQ --no_errors
if %ERRORLEVEL% equ 0 set _QT_LLVM_VER=18
call "%MAKER_SCRIPTS%\compare_versions.bat" "%_QT_VERSION%" 7.0 GEQ --no_errors
if %ERRORLEVEL% equ 0 set _QT_LLVM_VER=20

rem (3) *** patch Qt sources ***
if /I "%MAKER_ENV_UNKNOWN_SWITCH_1%" equ "--use_llvm20_patch" (
  pushd "%_QT_SOURCES_DIR%\qttools"
  call 7z x -y "%MAKER_TOOLS%\packages\qt663_qttools-llvm20-patch.7z" 1>NUL
  popd 
  set _QT_LLVM_VER=
)
echo QT_LLVM_VER: %_QT_LLVM_VER%

if "%MAKER_ENV_VERBOSE%" neq "" set _QT

rem (4) *** cleaning QT build if demanded ***
if "%_REBUILD%" neq "" (
  echo preparing rebuild...
  rmdir /s /q "%_QT_BIN_DIR%" 1>nul 2>nul
  rmdir /s /q "%_QT_BUILD_DIR%" 1>nul 2>nul
)

rem (5) *** testing for existing QT build ***
if not exist "%_QT_BIN_DIR%\bin\Qt6WebSockets.dll" goto :build_qt
if not exist "%_QT_BIN_DIR%\bin\lupdate.exe" goto :build_qt
call which Qt6WebSockets.dll 1>nul 2>nul
if %ERRORLEVEL% EQU 0 echo QT %_QT_VERSION% already available&goto :qt_install_done
set "PATH=%PATH%;%_QT_BIN_DIR%\bin"
call which Qt6WebSockets.dll 1>nul 2>nul
if %ERRORLEVEL% EQU 0 echo QT %_QT_VERSION% already available&goto :qt_install_done
echo error: QT %_QT_VERSION% seems to be prebuild but is not working
echo try rebuilding via '%~n0 --rebuild %_QT_VERSION%'
goto :Exit
:build_qt


rem (6) *** ensuring prerequisites ***

rem https://doc.qt.io/qt-6/windows-building.html
rem building Qt (libs and tools) requires:
rem
rem * mandatory: CMake 3.16 or newer
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
rem call "%_QT_SOURCES_DIR%\configure.bat" --help
rem 
echo.
echo rebuilding Qt %_QT_VERSION% from sources
echo see https://doc.qt.io/qt-6/windows-building.html
echo.
echo *** THIS REQUIRES VisualStudio 2019 or 2022 or Mingw-w64
echo *** THIS REQUIRES Python 3
echo *** THIS REQUIRES Cmake 3.16 or newer
echo *** OTPIONAL: Ninja
echo *** OTPIONAL: Perl
echo *** OTPIONAL: LLVM/Clang
echo *** OTPIONAL: Node.js
echo *** OTPIONAL: gRPC
echo *** OTPIONAL: Protobuf
echo *** OPTIONAL: gperf, bison, flex (for QtWebEngine)
echo.
rem ensure msvs version and amd64 target architecture
call "%MAKER_BUILD%\ensure_msvs.bat" GEQ2019 amd64
if %ERRORLEVEL% NEQ 0 (
  goto :Exit
)
rem validate cmake
call "%MAKER_BUILD%\validate_cmake.bat" GEQ3.16
if %ERRORLEVEL% NEQ 0 (
  goto :Exit
)
rem validate ninja
call "%MAKER_BUILD%\validate_ninja.bat" --no_errors
if %ERRORLEVEL% NEQ 0 (
  echo warning: NINJA is not available
  rem goto :Exit
)
rem validate llvm (due error: set LLVM_INSTALL_DIR + need to set the FEATURE_clang and FEATURE_clangcpp CMake variable to ON to re-evaluate this checks)
call "%MAKER_BUILD%\ensure_llvm.bat" %_QT_LLVM_VER% --no_errors
if %ERRORLEVEL% NEQ 0 (
  echo warning: LLVM CLANG is not available
  goto :Exit
)
rem validate perl (for opus optimization) (also see QNX/gperf see https://github.com/gperftools/gperftools/issues/1429)
call "%MAKER_BUILD%\validate_perl.bat" --no_errors
if %ERRORLEVEL% NEQ 0 (
  echo warning: PERL is not available
  rem goto :Exit
)
rem validate python
call "%MAKER_BUILD%\validate_python.bat" GEQ3 "%MSVS_TARGET_ARCHITECTURE%"
if %ERRORLEVEL% NEQ 0 (
  if /I "%PYTHON_ARCHITECTURE%" neq "%MSVS_TARGET_ARCHITECTURE%" (
    echo error: python architecture '%PYTHON_ARCHITECTURE%' does not match msvs target architecture '%MSVS_TARGET_ARCHITECTURE%'
  )
  goto :Exit
)

rem (7) *** setup QT dependencies ***
rem validate node.js 
call "%MAKER_BUILD%\ensure_nodejs.bat" GEQ14 --no_errors
if %ERRORLEVEL% NEQ 0 (
  echo warning: NODE.JS is not available
  goto :Exit
)
rem ensure gperf (for QtWebEngine see https://stackoverflow.com/questions/73498046/building-qt5-from-source-qtwebenginecore-module-will-not-be-built-tool-gperf-i)
rem WARNING: QtWebEngine won't be built. Tool gperf is required.
call "%MAKER_BUILD%\ensure_gperf.bat" --no_errors
if %ERRORLEVEL% NEQ 0 (
  echo warning: GPERF is not available
  rem goto :Exit
)
rem ensure bison
rem WARNING: QtWebEngine won't be built. Tool bison is required.
call "%MAKER_BUILD%\ensure_bison.bat" --no_errors
if %ERRORLEVEL% NEQ 0 (
  echo warning: BISON is not available
  rem goto :Exit
)
rem esnure flex
rem Support check for QtWebEngine failed: Tool flex is required.
call "%MAKER_BUILD%\ensure_flex.bat" --no_errors
if %ERRORLEVEL% NEQ 0 (
  echo warning: FLEX is not available
  rem goto :Exit
)
rem setup gRPC
rem call "%MAKER_BUILD%\build_grpc.bat" x64-windows
  rem pushd "%_QT_DIR%"
  rem call vcpkg install grpc:x64-windows
  rem popd
rem setup Protobuf
rem call "%MAKER_BUILD%\build_protobuf.bat" x64-windows
  rem pushd "%_QT_DIR%"
  rem call vcpkg install protobuf protobuf:x64-windows
  rem popd
rem setup Python packages
rem       clarify: created a dedicated  python venv for configuring/building ?
call python -m pip install html5lib
rem call python -m pip wheel html5lib


rem (8) *** configure QT build ***
:qt_configure
echo "%_QT_SOURCES_DIR%\configure.bat"  %%*>"%MAKER_BIN%\qtconfigure.bat"
if exist "%_QT_BUILD_DIR%\qtbase\bin\qt-cmake.bat" echo QT-CONFIGURE %_QT_VERSION% already done &goto :qt_configure_done
echo QT-CONFIGURE %_QT_VERSION%
rmdir /s /q "%_QT_BUILD_DIR%" 1>nul 2>nul
rmdir /s /q "%_QT_BIN_DIR%" 1>nul 2>nul 
mkdir "%_QT_BIN_DIR%"
mkdir "%_QT_BUILD_DIR%"
pushd "%_QT_BUILD_DIR%"
call "%_QT_SOURCES_DIR%\configure.bat" --help>"%_QT_DIR%\qt_build_%_QT_VERSION%_configure.log"
echo. "%_QT_SOURCES_DIR%\configure.bat" -prefix "%_QT_BIN_DIR%" -release -force-debug-info -separate-debug-info>>"%_QT_DIR%\qt_build_%_QT_VERSION%_configure.log"
call "%_QT_SOURCES_DIR%\configure.bat" -prefix "%_QT_BIN_DIR%" -release -force-debug-info -separate-debug-info>>"%_QT_DIR%\qt_build_%_QT_VERSION%_configure.log"
popd
:qt_configure_done

rem (9) *** perform QT build ***
:qt_build
if exist "%_QT_BIN_DIR%\bin\designer.exe" echo QT-BUILD %_QT_VERSION% already done &goto :qt_build_done
echo QT-BUILD %_QT_VERSION%
pushd "%_QT_BUILD_DIR%"
call cmake --build . --parallel 4
popd
:qt_build_done

rem (10) *** perform QT install ***
:qt_install
if not exist "%_QT_BIN_DIR%\bin\Qt6WebSockets.dll" goto :qt_install_do
if not exist "%_QT_BIN_DIR%\bin\lupdate.exe" goto :qt_install_do
goto :qt_install_test
:qt_install_do
  echo QT-INSTALL %_QT_VERSION%
  pushd "%_QT_BUILD_DIR%"
  call cmake --install .
  popd
  if not exist "%_QT_BIN_DIR%\bin\Qt6WebSockets.dll" echo error: QT-INSTALL %_QT_VERSION% FAILED&goto :qt_install_done
:qt_install_test
call which Qt6WebSockets.dll 1>nul 2>nul
if %ERRORLEVEL% NEQ 0 set "PATH=%PATH%;%_QT_BIN_DIR%\bin"
call which Qt6WebSockets.dll 1>nul 2>nul
if %ERRORLEVEL% EQU 0 echo QT-INSTALL %_QT_VERSION% available &goto :qt_install_done
echo error: QT-INSTALL %_QT_VERSION% failed
goto :Exit
:qt_install_done
rem -- create shortcuts
echo @start /D "%_QT_BIN_DIR%\bin" /MAX /B %_QT_BIN_DIR%\bin\designer.exe %%*>"%MAKER_BIN%\qtdesigner.bat"

rem (11) post configure QT
rem call "_QT_BIN_DIR%/bin/qt-configure-module.bat"

:Exit
cd /d "%_QT_DIR%"
cd /d "%_BQT_START_DIR%"
set _BQT_START_DIR=
set _REBUILD=
rem set _QT_VERSION=
rem set _QT_DIR=
rem set _QT_SOURCES_DIR=
rem set _QT_BUILD_DIR=
rem set _QT_BIN_DIR=
