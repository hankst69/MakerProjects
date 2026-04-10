@echo off
set "_BLLVM_START_DIR=%cd%"
call "%~dp0\maker_env.bat" %*
call "%MAKER_ENV_CORE%\clear_temp_envs.bat" "_LLVM_" 1>nul 2>nul

set "_LLVM_VERSION=%MAKER_VERSION%"
set "_LLVM_REBUILD=%MAKER_REBUILD%"
set "_LLVM_BUILD_ARCH=%MAKER_BUILD_ARCH%"
set "_LLVM_BUILD_TYPE=%MAKER_BUILD_TYPE%"
set "_LLVM_BUILD_MODE=%MAKER_BUILD_MODE%"
set "_LLVM_BUILD_SYSTEM=%MAKER_BUILD_SYSTEM%"
set "_LLVM_BUILD_CONFIG=%MAKER_BUILD_CONFIG%"

rem apply defaults
if "%_LLVM_VERSION%" equ "" set _LLVM_VERSION=
set "_LLVM_BUILD_INFO=LLVM %_LLVM_VERSION% %MAKER_BUILD_INFO%"


call "%MAKER_ENV_CORE%\stop_watch.bat"
set "_LLVM_BUILD_DATE_START=%_DATE_%"
set "_LLVM_BUILD_TIME_START=%_TIME_UI%"
set "_LLVM_BUILD_DATETIME_START=%_DATETIME_%"


rem (1) *** cloning LLVM sources ***
rem defines: LLVM_DIR
rem defines: LLVM_SOURCES_DIR
call "%MAKER_SCRIPTS%\clone_llvm.bat" %_LLVM_VERSION% %MAKER_MSG_VERBOSE%

if "%LLVM_DIR%" EQU "" (echo cloning LLVM %_LLVM_VERSION% failed &goto :EOF)
if "%LLVM_SOURCES_DIR%" EQU "" (echo cloning LLVM %_LLVM_VERSION% failed &goto :EOF)
if not exist "%LLVM_DIR%" (echo cloning LLVM %_LLVM_VERSION% failed &goto :EOF)
if not exist "%LLVM_SOURCES_DIR%" (echo cloning LLVM %_LLVM_VERSION% failed &goto :EOF)

set "_LLVM_BIN_DIR=%LLVM_DIR%\llvm%_LLVM_VERSION%-%_LLVM_BUILD_CONFIG%"
set "_LLVM_BUILD_DIR=%LLVM_SOURCES_DIR%\._%_LLVM_BUILD_CONFIG%"
set "_LLVM_LOGFILE=%LLVM_DIR%\.logs\llvm_build_%_LLVM_VERSION%_%_LLVM_BUILD_CONFIG%_%_LLVM_BUILD_DATETIME_START%.log"
if not exist "%LLVM_DIR%\.logs" mkdir "%LLVM_DIR%\.logs"

if "%MAKER_MSG_VERBOSE%" neq "" set _LLVM_


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
echo rebuilding %_LLVM_BUILD_INFO% from sources
echo see https://llvm.org/docs/GettingStarted.html#getting-the-source-code-and-building-llvm
echo.
echo *** THIS REQUIRES VisualStudio 2019 or 2022 or Mingw-w64
echo *** THIS REQUIRES Cmake 3.16 or newer
echo.

rem ensure msvs version and amd64 target architecture or MinGW gcc
if /I "%_LLVM_BUILD_SYSTEM%" equ "msvs" call "%MAKER_SCRIPTS%\ensure_msvs.bat" GEQ2019 amd64 %MAKER_MSG_VERBOSE%
if /I "%_LLVM_BUILD_SYSTEM%" equ "gnu" call "%MAKER_SCRIPTS%\ensure_gcc.bat" %MAKER_MSG_VERBOSE%
if %ERRORLEVEL% NEQ 0 (
  goto :EOF
)
if /I "%_LLVM_BUILD_SYSTEM%" neq "gnu" if /I "%_LLVM_BUILD_SYSTEM%" neq "msvs" (echo error: BuildSystem %_LLVM_BUILD_SYSTEM% is not available &goto :_exit)

rem validate cmake
call "%MAKER_SCRIPTS%\validate_cmake.bat" GEQ3.16
if %ERRORLEVEL% NEQ 0 (
  goto :EOF
)

if not exist "%_LLVM_BIN_DIR%" mkdir "%_LLVM_BIN_DIR%"
if not exist "%_LLVM_BUILD_DIR%" mkdir "%_LLVM_BUILD_DIR%"


rem (4) *** perform cmake configuration ***
:_configure
rem if exist "%_LLVM_BUILD_DIR%\lib\Analysis\LLVMAnalysis.dir\%_LLVM_BUILD_TYPE%\AliasAnalysis.obj" goto :_configure_done
  echo.
  echo CONFIGURE %_LLVM_BUILD_INFO%
  echo CONFIGURE %_LLVM_BUILD_INFO%>"%_LLVM_LOGFILE%"
  rem
  set "_LLVM_CONFIG_GENERATOR=Ninja"
  set "_LLVM_CONFIG_OPTIONS="
  if /I "%_LLVM_BUILD_SYSTEM%" equ "msvs" set "_LLVM_CONFIG_GENERATOR=Visual Studio %MSVS_VERSION_MAJOR% %MSVS_YEAR%"
  if /I "%_LLVM_BUILD_SYSTEM%" equ "msvs" set "_LLVM_CONFIG_OPTIONS=-A %_LLVM_BUILD_ARCH%"
  echo using generator "%_LLVM_CONFIG_GENERATOR%"
  rem
  rem set _LLVM_CONFIG_OPTIONS=%_LLVM_CONFIG_OPTIONS% -DLLVM_ENABLE_PROJECTS="all"
  rem set _LLVM_CONFIG_OPTIONS=%_LLVM_CONFIG_OPTIONS% -DLLVM_ENABLE_PROJECTS="bolt;clang;clang-tools-extra;flang;lld;lldb;mlir;polly;libc"
  set _LLVM_CONFIG_OPTIONS=%_LLVM_CONFIG_OPTIONS% -DLLVM_ENABLE_PROJECTS="clang;flang;lldb"
  rem
  rem if "%_LLVM_BUILD_MODE%" equ "shared" set "_LLVM_CONFIG_OPTIONS=%_LLVM_CONFIG_OPTIONS% -DBUILD_SHARED_LIBS=ON"
  rem if "%_LLVM_BUILD_MODE%" equ "static" set "_LLVM_CONFIG_OPTIONS=%_LLVM_CONFIG_OPTIONS% -DBUILD_SHARED_LIBS=OFF"
  set _LLVM_CONFIG_OPTIONS=%_LLVM_CONFIG_OPTIONS% -DCMAKE_BUILD_TYPE="%_LLVM_BUILD_TYPE%"
  rem
  echo. >>"%_LLVM_LOGFILE%"
  echo cmake -S "%LLVM_SOURCES_DIR%\llvm" -B "%_LLVM_BUILD_DIR%" --install-prefix "%_LLVM_BIN_DIR%" -G "%_LLVM_CONFIG_GENERATOR%" %_LLVM_CONFIG_OPTIONS% --log-level=VERBOSE
  echo cmake -S "%LLVM_SOURCES_DIR%\llvm" -B "%_LLVM_BUILD_DIR%" --install-prefix "%_LLVM_BIN_DIR%" -G "%_LLVM_CONFIG_GENERATOR%" %_LLVM_CONFIG_OPTIONS% --log-level=VERBOSE>>"%_LLVM_LOGFILE%" 2>&1
  call cmake -S "%LLVM_SOURCES_DIR%\llvm" -B "%_LLVM_BUILD_DIR%" --install-prefix "%_LLVM_BIN_DIR%" -G "%_LLVM_CONFIG_GENERATOR%" %_LLVM_CONFIG_OPTIONS% --log-level=VERBOSE>>"%_LLVM_LOGFILE%" 2>&1
rem :_configure_done
echo CONFIGURE %_LLVM_BUILD_INFO% done


rem (5) *** perform build ***
:_build
if exist "%_LLVM_BUILD_DIR%\%_LLVM_BUILD_TYPE%\bin\clang.exe" goto :_build_done
  echo.
  echo BUILD %_LLVM_BUILD_INFO%
  echo BUILD %_LLVM_BUILD_INFO%>>"%_LLVM_LOGFILE%" 2>&1
  cd /d "%_LLVM_BUILD_DIR%"
  echo cmake --build . --parallel --config %_LLVM_BUILD_TYPE%
  echo cmake --build . --parallel --config %_LLVM_BUILD_TYPE%>>"%_LLVM_LOGFILE%" 2>&1
  call cmake --build . --parallel --config %_LLVM_BUILD_TYPE%>>"%_LLVM_LOGFILE%" 2>&1
:_build_done
echo BUILD %_LLVM_BUILD_INFO% done


rem (7) *** perform install ***
:_install
if exist "%_LLVM_BIN_DIR%\bin\clang.exe" goto :_install_done
  echo.
  echo INSTALL %_LLVM_BUILD_INFO%
  echo INSTALL %_LLVM_BUILD_INFO%>>"%_LLVM_LOGFILE%" 2>&1
  cd /d "%_LLVM_BUILD_DIR%"
  echo cmake --install .
  echo cmake --install .>>"%_LLVM_LOGFILE%" 2>&1
  call cmake --install .>>"%_LLVM_LOGFILE%" 2>&1
)
:_install_done
if exist "%_LLVM_BIN_DIR%\bin\clang.exe" (
  echo INSTALL %_LLVM_BUILD_INFO% done
) else (
  echo error: INSTALL %_LLVM_BUILD_INFO% FAILED
)


rem (8) *** make LLVM available ***
:_validate
if not exist "%_LLVM_BIN_DIR%\bin\llc.exe" goto :_exit
if not exist "%_LLVM_BIN_DIR%\bin\clang.exe" goto :_exit
set "LLVM_INSTALL_DIR=%_LLVM_BIN_DIR%"
set "LLVM_VERSION=%_LLVM_VERSION%"
if "%MAKER_MSG_VERBOSE%" neq "" set LLVM_

call "%MAKER_SCRIPTS%\validate_llvm.bat" "%_LLVM_VERSION%" 1>nul 2>nul
if %ERRORLEVEL% EQU 0 goto :_exit
set "PATH=%PATH%;%_LLVM_BIN_DIR%\bin"

:_exit
cd /d "%LLVM_DIR%"
cd /d "%_BLLVM_START_DIR%"
set _BLLVM_START_DIR=
rem
call "%MAKER_ENV_CORE%\stop_watch.bat" "%_LLVM_BUILD_DATETIME_START%"
set "_LLVM_BUILD_DATE_STOP=%_DATE_%"
set "_LLVM_BUILD_TIME_STOP=%_TIME_UI%"
set "_LLVM_BUILD_DURATION=%_DIFFT_DUR_SS%"
echo.>>"%_LLVM_LOGFILE%"
echo.%_LLVM_BUILD_DATE_START% %_LLVM_BUILD_TIME_START%...%_LLVM_BUILD_TIME_STOP% ^(duration %_LLVM_BUILD_DURATION% sec^)>>"%_LLVM_LOGFILE%"
echo.
echo.BUILD-LOGFILE : "%_LLVM_LOGFILE%"
echo.BUILD-START   : %_LLVM_BUILD_DATE_START% %_LLVM_BUILD_TIME_START%
echo.BUILD-STOP    : %_LLVM_BUILD_DATE_STOP% %_LLVM_BUILD_TIME_STOP%
echo.BUILD-DURATION: %_LLVM_BUILD_DURATION% sec
rem
call "%MAKER_ENV_CORE%\clear_temp_envs.bat" "_LLVM_" 1>nul 2>nul
call "%MAKER_SCRIPTS%\validate_llvm.bat" --no_errors
