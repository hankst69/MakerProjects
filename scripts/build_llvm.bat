@echo off
set "_BLLVM_START_DIR=%cd%"
call "%~dp0\maker_env.bat" %*
call "%MAKER_SCRIPTS%\clear_temp_envs.bat" "_LLVM_" 1>nul 2>nul

set "_LLVM_VERSION=%MAKER_ENV_VERSION%"
set "_LLVM_BUILD_TYPE=%MAKER_ENV_BUILDTYPE%"
set "_LLVM_TGT_ARCH=%MAKER_ENV_ARCHITECTURE%"
set "_LLVM_REBUILD=%MAKER_ENV_REBUILD%"
rem apply defaults
if "%_LLVM_VERSION%" equ ""    set _LLVM_VERSION=
if "%_LLVM_BUILD_TYPE%" equ "" set _LLVM_BUILD_TYPE=Release
if "%_LLVM_TGT_ARCH%" equ ""   set _LLVM_TGT_ARCH=x64


rem (1) *** cloning LLVM sources ***
rem defines: _LLVM_DIR
rem defines: _LLVM_SOURCES_DIR
call "%MAKER_BUILD%\clone_llvm.bat" %_LLVM_VERSION%
if "%_LLVM_DIR%" EQU "" (echo cloning LLVM %_LLVM_VERSION% failed &goto :EOF)
if "%_LLVM_SOURCES_DIR%" EQU "" (echo cloning LLVM %_LLVM_VERSION% failed &goto :EOF)
if not exist "%_LLVM_DIR%" (echo cloning LLVM %_LLVM_VERSION% failed &goto :EOF)
if not exist "%_LLVM_SOURCES_DIR%" (echo cloning LLVM %_LLVM_VERSION% failed &goto :EOF)

set "_LLVM_BUILD_DIR=%_LLVM_DIR%\llvm_build%_LLVM_VERSION%"
set "_LLVM_BIN_DIR=%_LLVM_DIR%\llvm%_LLVM_VERSION%"

if "%MAKER_ENV_VERBOSE%" neq "" set _LLVM_

rem (2) *** removing prior build outputs ***
if "%_REBUILD%" equ "true" (
  echo preparing rebuild...
  rmdir /s /q "%_LLVM_BIN_DIR%" 1>nul 2>nul
  rmdir /s /q "%_LLVM_BUILD_DIR%" 1>nul 2>nul
)

if not exist "%_LLVM_BIN_DIR%\bin\clang.exe" goto :_rebuild
if not exist "%_LLVM_BIN_DIR%\lib\lldWasm.lib" goto :_rebuild
goto :_install_done


rem (3) *** ensuring prerequisites ***
:_rebuild
echo.
echo rebuilding LLVM %_LLVM_VERSION% from sources
echo see https://llvm.org/docs/GettingStarted.html#getting-the-source-code-and-building-llvm
echo.
echo *** THIS REQUIRES VisualStudio 2019 or 2022 or Mingw-w64
echo *** THIS REQUIRES Cmake 3.16 or newer
echo.

rem validate msvs and ensure amd64 target architecture
call "%MAKER_BUILD%\ensure_msvs.bat" GEQ2019 %_LLVM_TGT_ARCH%
if %ERRORLEVEL% NEQ 0 (
  goto :EOF
)
rem validate cmake
call "%MAKER_BUILD%\validate_cmake.bat" GEQ3.16
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
  echo cmake -S "%_LLVM_SOURCES_DIR%\llvm" -B "%_LLVM_BUILD_DIR%" -G "Visual Studio %MSVS_VERSION_MAJOR% %MSVS_YEAR%" -A %_LLVM_TGT_ARCH% --install-prefix "%_LLVM_BIN_DIR%" -DLLVM_ENABLE_PROJECTS="clang;lld;" -DLLVM_ENABLE_RTTI=ON -DCMAKE_BUILD_TYPE="%_LLVM_BUILD_TYPE%"
  call cmake -S "%_LLVM_SOURCES_DIR%\llvm" -B "%_LLVM_BUILD_DIR%" -G "Visual Studio %MSVS_VERSION_MAJOR% %MSVS_YEAR%" -A %_LLVM_TGT_ARCH% --install-prefix "%_LLVM_BIN_DIR%" -DLLVM_ENABLE_PROJECTS="clang;lld;" -DLLVM_ENABLE_RTTI=ON -DCMAKE_BUILD_TYPE="%_LLVM_BUILD_TYPE%"
:_configure_done
echo LLVM-CONFIGURE %_LLVM_VERSION% done


rem (5) *** perform build ***
:_build
if exist "%_LLVM_BUILD_DIR%\%_LLVM_BUILD_TYPE%\bin\clang.exe" goto :_build_done
  echo.
  echo LLVM-BUILD %_LLVM_VERSION% (%_LLVM_BUILD_TYPE%)
  cd /d "%_LLVM_BUILD_DIR%"
  call cmake --build . --parallel 4 --config %_LLVM_BUILD_TYPE%
:_build_done
echo LLVM-BUILD %_LLVM_VERSION% done


rem (7) *** perform install ***
:_install
if exist "%_LLVM_BIN_DIR%\bin\clang.exe" goto :_install_done
  echo.
  echo LLVM-INSTALL %_LLVM_VERSION%
  cd /d "%_LLVM_BUILD_DIR%"
  call cmake --install .
)
:_install_done
if exist "%_LLVM_BIN_DIR%\bin\clang.exe" (
  echo LLVM-INSTALL %_LLVM_VERSION% done
) else (
  echo error: LLVM-INSTALL %_LLVM_VERSION% FAILED
)


rem (8) *** make LLVM available ***
:_validate
if not exist "%_LLVM_BIN_DIR%\bin\clang.exe" goto :_exit
set "LLVM_INSTALL_DIR=%_LLVM_BIN_DIR%"
set "LLVM_VERSION=%_LLVM_VERSION%"
if "%MAKER_ENV_VERBOSE%" neq "" set LLVM_

call "%MAKER_BUILD%\validate_llvm.bat" "%_LLVM_VERSION%" 1>nul 2>nul
if %ERRORLEVEL% EQU 0 goto :_exit
set "PATH=%PATH%;%_LLVM_BIN_DIR%\bin"

:_exit
cd /d "%_LLVM_DIR%"
cd /d "%_BLLVM_START_DIR%"
set _BLLVM_START_DIR=
call "%MAKER_SCRIPTS%\clear_temp_envs.bat" "_LLVM_" 1>nul 2>nul
call "%MAKER_BUILD%\validate_llvm.bat" --no_errors
