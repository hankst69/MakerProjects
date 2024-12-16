@echo off
call "%~dp0\maker_env.bat"

set _VERSION=
set _REBUILD=
set _BUILD_TYPE=
:param_loop
if "%~1" equ "" goto :param_loop_exit
set "_ARG_=%~1"
if /I "%~1" equ "--rebuild"  (set "_REBUILD=true" &shift &goto :param_loop)
if /I "%~1" equ "-r"         (set "_REBUILD=true" &shift &goto :param_loop)
if /I "%~1" equ "Debug"      (set "_BUILD_TYPE=%~1" &shift &goto :param_loop)
if /I "%~1" equ "Release"    (set "_BUILD_TYPE=%~1" &shift &goto :param_loop)
if /I "%_ARG_:~0,1%" equ "-" (echo unknown switch '%~1' &shift &goto :param_loop)
if /I "!_ARG_:~0,1!" equ "-" (echo unknown switch '%~1' &shift &goto :param_loop)
if "%~1" neq "" if "%_VERSION%" equ "" (set "_VERSION=%~1" &shift &goto :param_loop)
if "%~1" neq "" (echo error: unknown argument '%~1' &shift &goto :param_loop)
:param_loop_exit
set _ARG_=

set "_LLVM_VERSION=%_VERSION%"
set "_LLVM_BUILD_TYPE=%_BUILD_TYPE%"
rem apply defaults
if "%_LLVM_VERSION%" equ "" set _LLVM_VERSION=
if "%_LLVM_BUILD_TYPE%" equ "" set _LLVM_BUILD_TYPE=Release
set "_LLVM_TGT_ARCH=x64"


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


rem (2) *** removing prior build outputs ***
if "%_REBUILD%" equ "true" (
  echo preparing rebuild...
  rmdir /s /q "%_LLVM_BIN_DIR%" 1>nul 2>nul
  rmdir /s /q "%_LLVM_BUILD_DIR%" 1>nul 2>nul
)


rem (3) *** ensuring prerequisites ***
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


rem (4) *** perform cmake configuration ***
:_configure
if exist "%_LLVM_BUILD_DIR%\lib\Analysis\LLVMAnalysis.dir\%_LLVM_BUILD_TYPE%\AliasAnalysis.obj" goto :_configure_done
echo.
echo LLVM-CONFIGURATION %_LLVM_VERSION% (%_LLVM_BUILD_TYPE% %_LLVM_TGT_ARCH%)
echo using generator "Visual Studio %MSVS_VERSION_MAJOR% %MSVS_YEAR%"
rem cmake -S <source_dir> -B <build_dir> -G <generator> [options] -A <architecture> [--trace] [--fresh] [-DCMAKE_BUILD_TYPE=Release] [ -DCMAKE_INSTALL_PREFIX="<install_folder>"]
rem for multiconfig generators like "Visual Studio ..." the BuildType option is ignored and needs to be specified at build time again
rem
rem cmake -S D:\GIT\Maker\tools\LLVM\llvm-project\llvm -B D:\GIT\Maker\tools\LLVM\llvm_build -G "Visual Studio 17 2022" -A x64 -DCMAKE_BUILD_TYPE=Release --install-prefix D:\GIT\Maker\tools\LLVM\llvm --trace --fresh
rem
echo cmake -S "%_LLVM_SOURCES_DIR%\llvm" -B "%_LLVM_BUILD_DIR%" -G "Visual Studio %MSVS_VERSION_MAJOR% %MSVS_YEAR%" -A %_LLVM_TGT_ARCH% --install-prefix "%_LLVM_BIN_DIR%" -DLLVM_ENABLE_PROJECTS="clang;lld;" -DCMAKE_BUILD_TYPE="%_LLVM_BUILD_TYPE%"
call cmake -S "%_LLVM_SOURCES_DIR%\llvm" -B "%_LLVM_BUILD_DIR%" -G "Visual Studio %MSVS_VERSION_MAJOR% %MSVS_YEAR%" -A %_LLVM_TGT_ARCH% --install-prefix "%_LLVM_BIN_DIR%" -DLLVM_ENABLE_PROJECTS="clang;lld;" -DCMAKE_BUILD_TYPE="%_LLVM_BUILD_TYPE%"
:_configure_done
echo LLVM-CONFIGURE %_LLVM_VERSION% done


rem (5) *** perform build ***
:_build
if exist "%_LLVM_BUILD_DIR%\%_LLVM_BUILD_TYPE%\bin\clang.exe" goto :_build_done
echo.
echo LLVM-BUILD %_LLVM_VERSION% (%_LLVM_BUILD_TYPE%)
cd "%_LLVM_BUILD_DIR%"
call cmake --build . --parallel 4 --config %_LLVM_BUILD_TYPE%
:_build_done
echo LLVM-BUILD %_LLVM_VERSION% done


rem (7) *** perform install ***
:_install
if exist "%_LLVM_BIN_DIR%\bin\clang.exe" goto :_install_done
  echo.
  echo LLVM-INSTALL %_LLVM_VERSION%
  pushd "%_LLVM_BUILD_DIR%"
  call cmake --install .
  popd
)
:_install_done
if exist "%_LLVM_BIN_DIR%\bin\clang.exe" (
  echo LLVM-INSTALL %_LLVM_VERSION% done
) else (
  echo error: LLVM-INSTALL %_LLVM_VERSION% FAILED
)


rem (8) *** make LLVM available ***
:_validate
rem set "LLVM_INSTALL_DIR=%_LLVM_BIN_DIR%\bin"
set "LLVM_INSTALL_DIR=%_LLVM_BIN_DIR%"

if not exist "%_LLVM_BIN_DIR%\bin\clang.exe" goto :Exit

call "%MAKER_SCRIPTS%\validate_llvm.bat" 1>nul 2>nul
if %ERRORLEVEL% EQU 0 goto :Exit
set "PATH=%PATH%;%_LLVM_BIN_DIR%\bin"

:Exit
cd "%_LLVM_DIR%"
call "%MAKER_SCRIPTS%\validate_llvm.bat" --no_errors
