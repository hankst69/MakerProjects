@rem https://doc.qt.io/qt-6/wasm.html
@echo off
set "_BQTW_START_DIR=%cd%"

call "%~dp0\maker_env.bat" %*
if "%MAKER_ENV_VERBOSE%" neq "" echo on

set "_QT_VERSION=%MAKER_ENV_VERSION%"
set "_QTW_REBUILD=%MAKER_ENV_REBUILD%"

rem apply defaults
if "%_QT_VERSION%" equ "" set _QT_VERSION=6.6.3

rem if we have to create a WASM build, we have to build the matching windows host version first
rem note that this call already ensures most of the prerequisites below

call "%MAKER_BUILD%\clone_qt.bat" "%_QT_VERSION%" %MAKER_ENV_VERBOSE%
rem if %ERRORLEVEL% NEQ 0 (echo cloning Qt %_QT_VERSION% failed &goto :Exit)
rem defines: _QT_DIR
rem defines: _QT_SOURCES_DIR
if "%_QT_DIR%" EQU "" (echo building Qt %_QT_VERSION% failed &goto :Exit)
if "%_QT_SOURCES_DIR%" EQU "" (echo building Qt %_QT_VERSION% failed &goto :Exit)
if not exist "%_QT_DIR%" (echo building Qt %_QT_VERSION% failed &goto :Exit)
if not exist "%_QT_SOURCES_DIR%" (echo building Qt %_QT_VERSION% failed &goto :Exit)

call "%MAKER_BUILD%\build_qt.bat" "%_QT_VERSION%" %MAKER_ENV_VERBOSE%
if %ERRORLEVEL% NEQ 0 (echo building Qt %_QT_VERSION% failed &goto :Exit)
rem defines: _QT_BIN_DIR
if "%_QT_BIN_DIR%" EQU "" (echo building Qt %_QT_VERSION% failed &goto :Exit)
if not exist "%_QT_BIN_DIR%" (echo building Qt %_QT_VERSION% failed &goto :Exit)
if not exist "%_QT_BIN_DIR%\bin\Qt6WebSockets.dll" (echo building Qt %_QT_VERSION% failed &goto :Exit)

rem echo test msvs
rem ensure msvs version and amd64 target architecture
call "%MAKER_BUILD%\ensure_msvs.bat" GEQ2019 amd64 %MAKER_ENV_VERBOSE%
if %ERRORLEVEL% NEQ 0 (
  goto :Exit
)
rem validate cmake
call "%MAKER_BUILD%\validate_cmake.bat" GEQ3.16 %MAKER_ENV_VERBOSE%
if %ERRORLEVEL% NEQ 0 (
  goto :Exit
)
rem validate ninja
call "%MAKER_BUILD%\validate_ninja.bat" --no_errors %MAKER_ENV_VERBOSE%
if %ERRORLEVEL% NEQ 0 (
  echo warning: NINJA is not available
  rem goto :Exit
)
rem validate llvm (set LLVM_INSTALL_DIR + need to set the FEATURE_clang and FEATURE_clangcpp CMake variable to ON to re-evaluate this checks)
call "%MAKER_BUILD%\ensure_llvm.bat" %_QT_LLVM_VER% --no_errors %MAKER_ENV_VERBOSE%
if %ERRORLEVEL% NEQ 0 (
  echo warning: LLVM CLANG is not available
  goto :Exit
)
rem validate emsdk (for Qt6.6 -> EMSDK 3.1.37) see https://doc.qt.io/qt-6/wasm.html
call "%MAKER_BUILD%\ensure_emsdk.bat" 3.1.37 --no_errors %MAKER_ENV_VERBOSE%
if %ERRORLEVEL% NEQ 0 (
  echo warning: EMSDK is not available
  goto :Exit
)
rem validate perl (for QNX/gperf see https://github.com/gperftools/gperftools/issues/1429)
call "%MAKER_BUILD%\validate_perl.bat" --no_errors %MAKER_ENV_VERBOSE%
if %ERRORLEVEL% NEQ 0 (
  echo warning: PERL is not available
  rem goto :Exit
)
rem validate python
call "%MAKER_BUILD%\validate_python.bat" 3 "%MSVS_TARGET_ARCHITECTURE%" %MAKER_ENV_VERBOSE%
if %ERRORLEVEL% NEQ 0 (
  rem if /I "%PYTHON_ARCHITECTURE%" neq "%MSVS_TARGET_ARCHITECTURE%" (
  rem   echo warning: PYTHON architecture '%PYTHON_ARCHITECTURE%' does not match MSVS target architecture '%MSVS_TARGET_ARCHITECTURE%'
  rem )
  echo warning: PYTHON is not available
  goto :Exit
)
rem ensure gperf (for QtWebEngine see https://stackoverflow.com/questions/73498046/building-qt5-from-source-qtwebenginecore-module-will-not-be-built-tool-gperf-i)
rem call "%MAKER_BUILD%\ensure_gperf.bat" --no_errors %MAKER_ENV_VERBOSE%
rem if %ERRORLEVEL% NEQ 0 (
rem   echo warning: GPERF is not available
rem   rem goto :Exit
rem )

rem clone qt again for wasm-build
call "%MAKER_BUILD%\clone_qt.bat" "%_QT_VERSION%" "qt-wasm" %MAKER_ENV_VERBOSE%
set "_QT_WASM_BUILD_DIR=%_QT_SOURCES_DIR%"
echo.
if "%_QTW_REBUILD%" neq "" (
  cd /d "%_BQTW_START_DIR%"
  rmdir /s /q "%_QT_WASM_BUILD_DIR%"
  call "%MAKER_BUILD%\clone_qt.bat" "%_QT_VERSION%" "qt-wasm" %MAKER_ENV_VERBOSE%
)

if "%MAKER_ENV_VERBOSE%" neq "" set _QT
if "%MAKER_ENV_VERBOSE%" neq "" echo.


rem 2) configure QT-WASM
:qt_configure
rem if exist "%_QT_WASM_BUILD_DIR%\qtbase\bin\qt-cmake.bat" echo QT-CONFIGURE WASM %_QT_VERSION% already done &goto :qt_configure_done
echo QT-CONFIGURE WASM %_QT_VERSION%
rem rmdir /s /q "%_QT_WASM_BUILD_DIR%"
rem mkdir "%_QT_WASM_BUILD_DIR%"
pushd "%_QT_WASM_BUILD_DIR%"
rem WARNING: QDoc will not be compiled, probably because clang's C and C++ libraries could not be located. This means that you cannot build the Qt documentation.
rem You may need to set CMAKE_PREFIX_PATH or LLVM_INSTALL_DIR to the location of your llvm installation.
rem Other than clang's libraries, you may need to install another package, such as clang itself, to provide the ClangConfig.cmake file needed to detect your libraries. Once this
rem file is in place, the configure script may be able to detect your system-installed libraries without further environment variables.
rem echo LLVM_INSTALL_DIR: "%LLVM_INSTALL_DIR%"
call configure -qt-host-path "%_QT_BIN_DIR%" -no-warnings-are-errors -platform wasm-emscripten -prefix "%_QT_WASM_BUILD_DIR%\qtbase" -- -DLLVM_INSTALL_DIR="%LLVM_INSTALL_DIR:~\=/%" >"%_QT_DIR%\qt_build_%_QT_VERSION%_wasm_configure.log"
rem call configure -qt-host-path "%_QT_BIN_DIR%" -no-warnings-are-errors -platform wasm-emscripten -prefix "%_QT_WASM_BUILD_DIR%\qtbase" -I "%_LLVM_BIN_DIR%\include" -L "%_LLVM_BIN_DIR%\lib" -- -DLLVM_INSTALL_DIR="%LLVM_INSTALL_DIR%" >"%_QT_DIR%\qt_build_%_QT_VERSION%_wasm_configure.log"
rem call "%_QT_SOURCES_DIR%\configure.bat" -qt-host-path "%_QT_BIN_DIR%" -platform wasm-emscripten -prefix "%_QT_WASM_BUILD_DIR%\qtbase" -I "%_LLVM_BIN_DIR%\include" -L "%_LLVM_BIN_DIR%\lib" >"%_QT_DIR%\qt_build_%_QT_VERSION%_wasm_configure.log"
rem call "%_QT_SOURCES_DIR%\configure.bat" -qt-host-path "%_QT_BIN_DIR%" -platform wasm-emscripten -prefix "%_QT_WASM_BUILD_DIR%\qtbase" >"%_QT_DIR%\qt_build_%_QT_VERSION%_wasm_configure.log"
rem call "%_QT_SOURCES_DIR%\configure.bat" -qt-host-path "%_QT_BIN_DIR%" -platform wasm-emscripten -prefix "%_QT_WASM_BUILD_DIR%\qtbase" -- -DLLVM_INSTALL_DIR "%LLVM_INSTALL_DIR%" -FEATURE_clang on FEATURE_clangcpp on>"%_QT_DIR%\qt_build_%_QT_VERSION%_wasm_configure.log"
popd
:qt_configure_done


rem 3) build QT-WASM
:qt_build
rem if exist "%_QT_BIN_DIR%\bin\designer.exe" echo QT-BUILD WASM %_QT_VERSION% already done &goto :qt_build_done
echo QT-BUILD WASM %_QT_VERSION%
pushd "%_QT_WASM_BUILD_DIR%"
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
rem set _QT_WASM_BUILD_DIR=
