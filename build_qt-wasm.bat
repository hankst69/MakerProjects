@echo off
set "_MAKER_ROOT=%~dp0"
rem https://doc.qt.io/qt-6/wasm.html

set _QT_VERSION=6.6.3
if "%~1" neq "" set "_QT_VERSION=%~1"

rem if we have to create a WASM build, we have to build the matching windows host version first
call "%_MAKER_ROOT%\build_qt.bat" "%~1"
echo.
cd "%_MAKER_ROOT%
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
rem ...tbd
:test_msvs_success

rem echo test cmake
call which cmake.exe 1>nul 2>nul
if %ERRORLEVEL% EQU 0 goto :test_cmake_success
echo error: CMAKE is not available
goto :EOF
:test_cmake_success

rem echo test ninja
call which ninja.exe 1>nul 2>nul
if %ERRORLEVEL% EQU 0 goto :test_ninja_success
echo warning: NINJA is not available
rem goto :EOF
:test_ninja_success

rem echo test llvm (set LLVM_INSTALL_DIR + need to set the FEATURE_clang and FEATURE_clangcpp CMake variable to ON to re-evaluate this checks)
call which clang.exe 1>nul 2>nul
if %ERRORLEVEL% EQU 0 goto :test_llvm_success
echo warning: LLVM Clang is not available
rem goto :EOF
:test_llvm_success

rem echo test emsdk
call which emcc.bat 1>nul 2>nul
if %ERRORLEVEL% EQU 0 goto :test_emsdk_success
echo error: EMSDK not available
goto :EOF
:test_emsdk_success
call em++ --version
call emcc --version
:test_emsdk_ok

rem echo test perl (+ gperf + qnx)
call which perl.exe 1>nul 2>nul
if %ERRORLEVEL% EQU 0 goto :test_perl_success
echo error: perl is not available
goto :EOF
:test_perl_success

rem echo test python
call which python.exe 1>nul 2>nul
if %ERRORLEVEL% EQU 0 goto :test_python_success
echo error: python is not available
goto :EOF
:test_python_success


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


cd "%_QT_DIR%"
