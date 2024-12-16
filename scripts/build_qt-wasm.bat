@rem https://doc.qt.io/qt-6/wasm.html
@echo off
call "%~dp0\maker_env.bat"
set "_BQTW_START_DIR=%cd%"

set _QT_VERSION=6.6.3
if "%~1" neq "" set "_QT_VERSION=%~1"

rem if we have to create a WASM build, we have to build the matching windows host version first
rem note that this call already ensures most of the prerequisites below
call "%MAKER_ROOT%\build_qt.bat" "%~1"
echo.

cd "%MAKER_ROOT%
rem defines: _QT_DIR
rem defines: _QT_SOURCES_DIR
rem defines: _QT_BIN_DIR
if "%_QT_DIR%" EQU "" (echo building Qt %_QT_VERSION% failed &goto :EOF)
if "%_QT_SOURCES_DIR%" EQU "" (echo building Qt %_QT_VERSION% failed &goto :EOF)
if "%_QT_BIN_DIR%" EQU "" (echo building Qt %_QT_VERSION% failed &goto :EOF)
if not exist "%_QT_DIR%" (echo building Qt %_QT_VERSION% failed &goto :EOF)
if not exist "%_QT_SOURCES_DIR%" (echo building Qt %_QT_VERSION% failed &goto :EOF)
if not exist "%_QT_BIN_DIR%" (echo building Qt %_QT_VERSION% failed &goto :EOF)
if not exist "%_QT_BIN_DIR%\bin\Qt6WebSockets.dll" (echo building Qt %_QT_VERSION% failed &goto :EOF)

set "_QT_BUILD_DIR=%_QT_DIR%\qt-wasm%_QT_VERSION%"

rem echo test msvs
rem ensure msvs version and amd64 target architecture
call "%MAKER_SCRIPTS%\ensure_msvs.bat" GEQ2019 amd64
if %ERRORLEVEL% NEQ 0 (
  goto :Exit
)
rem validate cmake
call "%MAKER_SCRIPTS%\validate_cmake.bat" GEQ3.16
if %ERRORLEVEL% NEQ 0 (
  goto :Exit
)
rem validate ninja
call "%MAKER_SCRIPTS%\validate_ninja.bat" --no_errors
if %ERRORLEVEL% NEQ 0 (
  echo warning: NINJA is not available
  rem goto :Exit
)
rem validate llvm (set LLVM_INSTALL_DIR + need to set the FEATURE_clang and FEATURE_clangcpp CMake variable to ON to re-evaluate this checks)
call "%MAKER_SCRIPTS%\validate_llvm.bat" --no_errors
if %ERRORLEVEL% NEQ 0 (
  echo warning: LLVM CLANG is not available - trying to provide
  call "%MAKER_ROOT%\build_llvm.bat"
  call "%MAKER_SCRIPTS%\validate_llvm.bat"
  if %ERRORLEVEL% NEQ 0 (
    goto :Exit
  )
)
rem validate emsdk
call "%MAKER_SCRIPTS%\validate_emsdk.bat" --no_errors
if %ERRORLEVEL% NEQ 0 (
  echo warning: EMSDK is not available - trying to provide
  call "%MAKER_ROOT%\build_emsdk.bat"
  call "%MAKER_SCRIPTS%\validate_emsdk.bat" --no_errors
  if %ERRORLEVEL% NEQ 0 (
    goto :Exit
  )
)
rem validate perl (for QNX/gperf see https://github.com/gperftools/gperftools/issues/1429)
call "%MAKER_SCRIPTS%\validate_perl.bat" --no_errors
if %ERRORLEVEL% NEQ 0 (
  echo warning: PERL is not available
  rem goto :Exit
)
rem validate python
call "%MAKER_SCRIPTS%\validate_python.bat" 3 "%MSVS_TARGET_ARCHITECTURE%"
if %ERRORLEVEL% NEQ 0 (
  rem if /I "%PYTHON_ARCHITECTURE%" neq "%MSVS_TARGET_ARCHITECTURE%" (
  rem   echo warning: PYTHON architecture '%PYTHON_ARCHITECTURE%' does not match MSVS target architecture '%MSVS_TARGET_ARCHITECTURE%'
  rem )
  echo warning: PERL is not available
  goto :Exit
)
rem ensure gperf (for QtWebEngine see https://stackoverflow.com/questions/73498046/building-qt5-from-source-qtwebenginecore-module-will-not-be-built-tool-gperf-i)
call "%MAKER_SCRIPTS%\ensure_gperf.bat" --no_errors
if %ERRORLEVEL% NEQ 0 (
  echo warning: gperf is not available
  rem goto :Exit
)


rem 2) configure QT-WASM
:qt_configure
if exist "%_QT_BUILD_DIR%\qtbase\bin\qt-cmake.bat" echo QT-CONFIGURE WASM %_QT_VERSION% already done &goto :qt_configure_done
echo QT-CONFIGURE WASM %_QT_VERSION%
rmdir /s /q "%_QT_BUILD_DIR%"
mkdir "%_QT_BUILD_DIR%"
pushd "%_QT_BUILD_DIR%"
rem call python -m pip install html5lib
rem call python -m pip wheel html5lib
call "%_QT_SOURCES_DIR%\configure.bat" -qt-host-path "%_QT_BIN_DIR%" -platform wasm-emscripten -prefix "%_QT_BUILD_DIR%\qtbase" >"%_QT_DIR%\qt_build_%_QT_VERSION%_wasm_configure.log"
rem call "%_QT_SOURCES_DIR%\configure.bat" -qt-host-path "%_QT_BIN_DIR%" -platform wasm-emscripten -prefix "%_QT_BUILD_DIR%\qtbase" -LLVM_INSTALL_DIR "%LLVM_INSTALL_DIR%" -FEATURE_clang on FEATURE_clangcpp on>"%_QT_DIR%\qt_build_%_QT_VERSION%_wasm_configure.log"
popd
:qt_configure_done


rem 3) build QT-WASM
:qt_build
rem if exist "%_QT_BIN_DIR%\bin\designer.exe" echo QT-BUILD WASM %_QT_VERSION% already done &goto :qt_build_done
echo QT-BUILD WASM %_QT_VERSION%
pushd "%_QT_BUILD_DIR%"
rem call cmake --build . --parallel
rem call cmake --build . -t qtbase -t qtdeclarative [-t another_module]
call cmake --build . -t qtbase -t qtdeclarative 
rem https://doc.qt.io/qt-6/wasm.html#supported-qt-modules
call cmake --build . -t qtCore -t qtGui -t qtNetwork -t qtWidgets -t qtQml -t qtQuick -t qtQuickControls -t qtQuickLayouts -t qt5CoreCompatibilityAPIs -t qtImageFormats -t qtOpenGL -t qtSVG -t qtWebSockets
rem future WASM supported modules:
rem call cmake --build . -t qtThreading -t qtConcurrent -t qtEmscriptenAsyncify -t qtSockets
popd
:qt_build_done


rem 4) install QT-WASM
:qt_install
rem if ... echo QT-INSTALL echo QT-INSTALL WASM %_QT_VERSION% already done
rem echo QT-INSTALL echo QT-INSTALL WASM %_QT_VERSION% done
rem set "PATH=%PATH%;%_QT_BIN_DIR%\bin"
rem echo QT-INSTALL echo QT-INSTALL WASM %_QT_VERSION% done
:qt_install_done


:Exit
cd /d "%_QT_DIR%"
cd /d "%_BQTW_START_DIR%"
set _BQTW_START_DIR=
rem set _QT_VERSION=
rem set _QT_DIR=
rem set _QT_SOURCES_DIR=
rem set _QT_BUILD_DIR=
rem set _QT_BIN_DIR=
