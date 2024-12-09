@echo off
call "%~dp0\maker_env.bat"

set _LLVM_VERSION=
set _LLVM_TGT_ARCH=x64
set _LLVM_BUILD_TYPE=Release
rem set _LLVM_BUILD_TYPE=Debug

set _REBUILD=
:param_loop
if /I "%~1" equ "--rebuild"    (set "_REBUILD=true" &shift &goto :param_loop)
if /I "%~1" equ "-r"           (set "_REBUILD=true" &shift &goto :param_loop)
if /I "%~1" equ "Debug"        (set "_LLVM_BUILD_TYPE=%~1" &shift &goto :param_loop)
if /I "%~1" equ "Release"      (set "_LLVM_BUILD_TYPE=%~1" &shift &goto :param_loop)
rem if /I "%~1" equ "RelWithDebug" (set "_LLVM_BUILD_TYPE=%~1" &shift &goto :param_loop)
if "%~1" neq "" if "%_LLVM_VERSION%" equ "" (set "_LLVM_VERSION=%~1" &shift &goto :param_loop)
if "%~1" neq ""              (echo error: unknonwn argument '%~1' &goto :EOF)

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
call "%MAKER_SCRIPTS%\ensure_msvs.bat" GEQ2019 %_LLVM_TGT_ARCH%
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
:_configure
if exist "%_LLVM_BUILD_DIR%\lib\Analysis\LLVMAnalysis.dir\%_LLVM_BUILD_TYPE%\AliasAnalysis.obj" goto :_configure_done
echo.
echo LLVM-CONFIGURATION %_LLVM_VERSION% (Visual Studio %MSVS_VERSION_MAJOR% %MSVS_YEAR% x64)
echo using generator "Visual Studio %MSVS_VERSION_MAJOR% %MSVS_YEAR%"
rem cmake -S <source_dir> -B <build_dir> -G <generator> [options] -A <architecture>
rem cmake -S D:\GIT\Maker\tools\LLVM\llvm-project\llvm -B D:\GIT\Maker\tools\LLVM\llvm_build -G "Visual Studio 17 2022" -A x64 -DCMAKE_BUILD_TYPE=Release --install-prefix D:\GIT\Maker\tools\LLVM\llvm --trace --fresh
rem echo cmake -S "%_LLVM_SOURCES_DIR%\llvm" -B "%_LLVM_BUILD_DIR%" -G "Visual Studio %MSVS_VERSION_MAJOR% %MSVS_YEAR%" -A %_LLVM_TGT_ARCH% -DCMAKE_BUILD_TYPE="%_LLVM_BUILD_TYPE%" -DCMAKE_INSTALL_PREFIX="%_LLVM_BIN_DIR%" -DLLVM_ENABLE_PROJECTS="clang;lld;"
echo cmake -S "%_LLVM_SOURCES_DIR%\llvm" -B "%_LLVM_BUILD_DIR%" -G "Visual Studio %MSVS_VERSION_MAJOR% %MSVS_YEAR%" -A %_LLVM_TGT_ARCH% --install-prefix "%_LLVM_BIN_DIR%" -DLLVM_ENABLE_PROJECTS="clang;lld;" -DCMAKE_BUILD_TYPE="%_LLVM_BUILD_TYPE%"
call cmake -S "%_LLVM_SOURCES_DIR%\llvm" -B "%_LLVM_BUILD_DIR%" -G "Visual Studio %MSVS_VERSION_MAJOR% %MSVS_YEAR%" -A %_LLVM_TGT_ARCH% --install-prefix "%_LLVM_BIN_DIR%" -DLLVM_ENABLE_PROJECTS="clang;lld;" -DCMAKE_BUILD_TYPE="%_LLVM_BUILD_TYPE%"
:_configure_done
echo LLVM-CONFIGURE %_LLVM_VERSION% done


rem (7) *** perform LLVM build ***
:_build
if exist "%_LLVM_BIN_DIR%\build\%_LLVM_BUILD_TYPE%\bin\llvm-link.exe" goto :_build_done
echo.
echo LLVM-BUILD %_LLVM_VERSION% (%_LLVM_BUILD_TYPE%)
cd "%_LLVM_BUILD_DIR%"
call cmake --build . --parallel 4 --config %_LLVM_BUILD_TYPE%
:_build_done
echo LLVM-BUILD %_LLVM_VERSION% done


rem (8) *** perform LLVM install ***
:_install
rem if not exist "%_LLVM_BIN_DIR%\bin\Qt6WebSockets.dll" (
  echo.
  echo LLVM-INSTALL %_LLVM_VERSION%
  pushd "%_LLVM_BUILD_DIR%"
  call cmake --install .
  popd
rem   if not exist "%_LLVM_BIN_DIR%\bin\Qt6WebSockets.dll" echo error: QT-INSTALL %_QT_VERSION% FAILED&goto :qt_install_done
rem )
:_install_done

cd "%_LLVM_DIR%"