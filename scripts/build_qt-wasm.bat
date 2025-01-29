@rem https://doc.qt.io/qt-6/wasm.html
@echo off
set "_BQTW_START_DIR=%cd%"

call "%~dp0\maker_env.bat" %*
if "%MAKER_ENV_VERBOSE%" neq "" echo on

set "_QTW_VERSION=%MAKER_ENV_VERSION%"
set "_QTW_REBUILD=%MAKER_ENV_REBUILD%"

rem apply defaults
if "%_QTW_VERSION%" equ "" set _QTW_VERSION=6.6.3


rem (1) *** build QT ***
rem if we have to create a WASM build, we have to build the matching windows host version first
call "%MAKER_BUILD%\build_qt.bat" "%_QTW_VERSION%" %MAKER_ENV_VERBOSE%
if %ERRORLEVEL% NEQ 0 (echo building Qt %_QTW_VERSION% failed &goto :qtw_exit)
rem defines: QT_DIR
rem defines: QT_SOURCES_DIR
rem defines: QT_BIN_DIR
rem defines: QT_VERSION
rem defines: QT_CMAKE
rem defines: QT_LLVM_VER
if "%QT_BIN_DIR%" EQU "" (echo building Qt %_QTW_VERSION% failed &goto :qtw_exit)
if not exist "%QT_BIN_DIR%" (echo building Qt %_QTW_VERSION% failed &goto :qtw_exit)
if not exist "%QT_BIN_DIR%\bin\Qt6WebSockets.dll" (echo building Qt %_QTW_VERSION% failed &goto :qtw_exit)
rem if not exist "%QT_CMAKE%" (echo building Qt %_QTW_VERSION% failed &goto :qtw_exit)


rem (2) *** prepare folders ***
set "_QTW_BIN_DIR=%QT_DIR%\qtwasm%_QTW_VERSION%"
set "_QTW_BUILD_DIR=%QT_DIR%\qtwasm_build%_QTW_VERSION%"

if "%_QTW_REBUILD%" neq "" (
  echo preparing rebuild...
  rmdir /s /q "%_QTW_BIN_DIR%" 1>nul 2>nul
  rmdir /s /q "%_QTW_BUILD_DIR%" 1>nul 2>nul
)

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
  goto :qt_exit
)
rem validate node.js 
call "%MAKER_BUILD%\ensure_nodejs.bat" GEQ14 --no_errors
if %ERRORLEVEL% NEQ 0 (
  echo warning: NODE.JS is not available
  goto :qt_exit
)
rem validate perl (for QNX/gperf see https://github.com/gperftools/gperftools/issues/1429)
rem call "%MAKER_BUILD%\validate_perl.bat" --no_errors %MAKER_ENV_VERBOSE%
rem if %ERRORLEVEL% NEQ 0 (
rem   echo warning: PERL is not available
rem   rem goto :qtw_exit
rem )
rem ensure gperf (for QtWebEngine see https://stackoverflow.com/questions/73498046/building-qt5-from-source-qtwebenginecore-module-will-not-be-built-tool-gperf-i)
rem call "%MAKER_BUILD%\ensure_gperf.bat" --no_errors %MAKER_ENV_VERBOSE%
rem if %ERRORLEVEL% NEQ 0 (
rem   echo warning: GPERF is not available
rem   rem goto :qtw_exit
rem )


rem (6) *** clone qt again for wasm-build ***
rem call "%MAKER_BUILD%\clone_qt.bat" "%_QTW_VERSION%" "qt-wasm" %MAKER_ENV_VERBOSE%
rem set "_QTW_BUILD_DIR=%QT_SOURCES_DIR%"
rem echo.
rem if "%_QTW_REBUILD%" neq "" (
rem   cd /d "%_BQTW_START_DIR%"
rem   rmdir /s /q "%_QTW_BUILD_DIR%"
rem   call "%MAKER_BUILD%\clone_qt.bat" "%_QTW_VERSION%" "qt-wasm" %MAKER_ENV_VERBOSE%
rem )
rem if "%MAKER_ENV_VERBOSE%" neq "" set _QTW_


rem (7) *** configure QT-WASM ***
:qtw_conigure
if exist "%_QTW_BUILD_DIR%\qtbase\cmake_install.cmake" echo QT-CONFIGURE WASM %_QTW_VERSION% already done &goto :qtw_build
echo QT-CONFIGURE WASM %_QTW_VERSION%
rem rmdir /s /q "%_QTW_BUILD_DIR%"
mkdir "%_QTW_BUILD_DIR%"
pushd "%_QTW_BUILD_DIR%"
rem call "%QT_SOURCES_DIR%\configure.bat" -prefix "%_QTW_BIN_DIR%" -qt-host-path "%QT_BIN_DIR%" -platform wasm-emscripten -I "%_LLVM_BIN_DIR%\include" -L "%_LLVM_BIN_DIR%\lib" -- --log-level=VERBOSE >"%QT_DIR%\qtwasm_build%_QTW_VERSION%_configure.log"
>"%QT_DIR%\qtwasm_build%_QTW_VERSION%_configure.log" call "%QT_SOURCES_DIR%\configure.bat" -prefix "%_QTW_BIN_DIR:~\=/%" -qt-host-path "%QT_BIN_DIR:~\=/%" -platform wasm-emscripten -- -DLLVM_INSTALL_DIR="%LLVM_INSTALL_DIR:~\=/%"
popd


rem (8) *** build QT-WASM ***
:qtw_build
rem if exist "%QT_BIN_DIR%\bin\designer.exe" echo QT-BUILD WASM %_QTW_VERSION% already done &goto :qt_build_done
echo QT-BUILD WASM %_QTW_VERSION%
rem call cmake --help
rem call cmake --build . --parallel 4
rem call cmake --build . -t qtbase -t qtdeclarative [-t another_module]
rem https://doc.qt.io/qt-6/wasm.html#supported-qt-modules
rem call cmake --build . -t qtCore -t qtGui -t qtNetwork -t qtWidgets -t qtQml -t qtQuick -t qtQuickControls -t qtQuickLayouts -t qt5CoreCompatibilityAPIs -t qtImageFormats -t qtOpenGL -t qtSVG -t qtWebSockets -t qt6Mqtt
rem future WASM supported modules:
rem call cmake --build . -t qtThreading -t qtConcurrent -t qtEmscriptenAsyncify -t qtSockets
call cmake --build "%_QTW_BUILD_DIR%"
:qtw_build_done


rem (9) *** install QT-WASM ***
:qtw_install
rem if ... echo QT-INSTALL echo QT-INSTALL WASM %_QTW_VERSION% already done
call cmake --install "%_QTW_BUILD_DIR%" --prefix "%_QTW_BIN_DIR%" --verbose
:qtw_install_done


:qtw_exit
cd /d "%QT_DIR%"
cd /d "%_BQTW_START_DIR%"
set _BQTW_START_DIR=
