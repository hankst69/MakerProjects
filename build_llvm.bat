@echo off
call "%~dp0\maker_env.bat"

set _LLVM_VERSION=
set _REBUILD=
:param_loop
if /I "%~1" equ "--rebuild" (set "_REBUILD=true" &shift &goto :param_loop)
if /I "%~1" equ "-r"        (set "_REBUILD=true" &shift &goto :param_loop)
if "%~1" neq ""             (set "_LLVM_VERSION=%~1" &shift &goto :param_loop)

rem (1) *** cloning LLVM sources ***
rem defines: _LLVM_DIR
rem defines: _LLVM_SOURCES_DIR
call "%MAKER_ROOT%\clone_llvm.bat" %_LLVM_VERSION%
if "%_LLVM_DIR%" EQU "" (echo cloning LLVM %_LLVM_VERSION% failed &goto :EOF)
if "%_LLVM_SOURCES_DIR%" EQU "" (echo cloning LLVM %_LLVM_VERSION% failed &goto :EOF)
if not exist "%_LLVM_DIR%" (echo cloning LLVM %_LLVM_VERSION% failed &goto :EOF)
if not exist "%_LLVM_SOURCES_DIR%" (echo cloning LLVM %_LLVM_VERSION% failed &goto :EOF)

set "_LLVM_BUILD_DIR=%_LLVM_DIR%\llvm_build%_LLVM_VERSION%"
set "_LLVM_BIN_DIR=%_LLVM_DIR%\llvm%_LLVM_VERSION%"

rem (2) *** cleaning QT build if demanded ***
if "%_REBUILD%" equ "true" (
  echo preparing rebuild...
  rmdir /s /q "%_LLVM_BIN_DIR%" 1>nul 2>nul
  rmdir /s /q "%_LLVM_BUILD_DIR%" 1>nul 2>nul
)

rem (4) *** ensuring prerequisites ***
echo.
echo rebuilding LLVM %_LLVM_VERSION% from sources
echo see https://llvm.org/docs/GettingStarted.html#getting-the-source-code-and-building-llvm
echo.
echo *** THIS REQUIRES VisualStudio 2019 or 2022 or Mingw-w64
echo *** THIS REQUIRES Cmake 3.16 or newer
echo.

rem validate msvs and ensure amd64 target architecture
call "%MAKER_SCRIPTS%\ensure_msvs.bat" GEQ2019 amd64
if %ERRORLEVEL% NEQ 0 (
  goto :EOF
)
rem validate cmake
call "%MAKER_SCRIPTS%\validate_cmake.bat" GEQ3.16
if %ERRORLEVEL% NEQ 0 (
  goto :EOF
)

if not exist "%_LLVM_BIN_DIR%" mkdir "%_LLVM_BIN_DIR%"
if not exist "%_LLVM_BUILD_DIR%" mkdir "%_LLVM_BUILD_DIR%"


rem (6) *** perform LLVM Cmake configuration ***
echo LLVM-CONFIGURATION %_QT_VERSION%
pushd "%_LLVM_BUILD_DIR%"
rem cmake -S llvm -B build -G <generator> [options]
call cmake -S "%_LLVM_SOURCES_DIR%\llvm" -B build -G "Visual Studio %MSVS_VERSION_MAJOR% %MSVS_YEAR%" -DCMAKE_INSTALL_PREFIX="%_LLVM_BIN_DIR%" -DLLVM_ENABLE_PROJECTS="clang;lld;" -DCMAKE_BUILD_TYPE=Release
popd


rem (7) *** perform LLVM build ***
:_build
if exist "%_LLVM_BIN_DIR%\bin\designer.exe" echo LLVM-BUILD %_LLVM_VERSION% already done &goto :_build_done
echo LLVM-BUILD %_LLVM_VERSION%
pushd "%_LLVM_BUILD_DIR%"
call cmake --build . --parallel
popd
:_build_done


rem (8) *** perform LLVM install ***
:_install
rem if not exist "%_LLVM_BIN_DIR%\bin\Qt6WebSockets.dll" (
  echo LLVM-INSTALL %_LLVM_VERSION%
  pushd "%_LLVM_BUILD_DIR%"
  call cmake --install .
  popd
rem   if not exist "%_LLVM_BIN_DIR%\bin\Qt6WebSockets.dll" echo error: QT-INSTALL %_QT_VERSION% FAILED&goto :qt_install_done
rem )
:_install_done
