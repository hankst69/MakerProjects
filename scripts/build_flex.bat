@rem >choco info winflexbison          &rem bison-2.7.0 flex-2.6.3
@rem >choco info winflexbison3         &rem bison-3.7.4 flex-2.6.4
@echo off
set "_BMFL_START_DIR=%cd%"

call "%~dp0\maker_env.bat" %*
rem if "%MAKER_ENV_VERBOSE%" neq "" echo on

rem init with command line arguments
set "_FLEX_VERSION=%MAKER_ENV_VERSION%"
set "_FLEX_BUILD_TYPE=%MAKER_ENV_BUILDTYPE%"
set "_FLEX_TGT_ARCH=%MAKER_ENV_ARCHITECTURE%"

rem apply defaults
rem if "%_FLEX_VERSION%"    equ "" set _FLEX_VERSION=2.4.1
if "%_FLEX_VERSION%"    equ "" set _FLEX_VERSION=2.6.3
rem if "%_FLEX_BUILD_TYPE%" equ "" set _FLEX_BUILD_TYPE=Release
rem set "_FLEX_TGT_ARCH=x64"

rem take shortcut if possible
set ERRORLEVEL=
call "%MAKER_BUILD%\validate_flex.bat" %_FLEX_VERSION% 1>nul 2>nul
if %ERRORLEVEL% EQU 0 goto :exit_script
if "%MAKER_ENV_VERBOSE%" neq "" echo on

rem install/build...
rem a) install using predownloaded zip files:
rem set "_FLEX_DIR=%MAKER_TOOLS%\Flex"
rem set "_FLEX_BIN_DIR=%_FLEX_DIR%\flex-%_FLEX_VERSION%"
rem if not exist "%_FLEX_BIN_DIR%" mkdir "%_FLEX_BIN_DIR%"
rem if exist "%_FLEX_BIN_DIR%\bin\flex.exe" goto :test_FLEX_succes
rem unzip flex into %_FLEX_DIR%
rem pushd "%_FLEX_BIN_DIR%"
rem call 7z x -y "%MAKER_TOOLS%\packages\bison-2.4.1-dep.zip" 1>NUL
rem call 7z x -y "%MAKER_TOOLS%\packages\bison-2.4.1-lib.zip" 1>NUL
rem call 7z x -y "%MAKER_TOOLS%\packages\bison-2.4.1-bin.zip" 1>NUL
rem call 7z x -y "%MAKER_TOOLS%\packages\bison-2.4.1-src.zip" 1>NUL
rem popd
rem if exist "%_FLEX_BIN_DIR%\bin\flex.exe" goto :test_FLEX_succes
rem
rem b) install using choco:
set "_FLEX_BIN_DIR=%MAKER_BIN%"
call "%MAKER_BUILD%\ensure_choco.bat"
if %ERRORLEVEL% NEQ 0 (
  echo error: CHOCO is not available
  goto :exit_script
)
set "_CHOCO_BIN_BIN=%_CHOCO_BIN%\bin"
if exist "%_CHOCO_BIN_BIN%\win_flex.exe" goto :win_FLEX_installed
call choco install winflexbison --yes --force
if not exist "%_CHOCO_BIN_BIN%\win_flex.exe" (
  echo. error: install FLEX failed
  goto :exit_script
)
:win_FLEX_installed
rem echo @call "%_CHOCO_BIN_BIN%\win_flex.exe" %%* >"%MAKER_BIN%\flex.bat"
rem goto :test_FLEX_succes
copy /Y "%_CHOCO_BIN_BIN%\win_flex.exe" "%_CHOCO_BIN_BIN%\flex.exe" 1>nul 2>nul
call "%MAKER_BUILD%\validate_flex.bat" %_FLEX_VERSION% --no_info --no_errors
if %ERRORLEVEL% EQU 0 goto :exit_script
set "Path=%_CHOCO_BIN_BIN%;%Path%"
goto :exit_script

:test_FLEX_succes
call "%MAKER_BUILD%\validate_flex.bat" %_FLEX_VERSION% --no_errors
if %ERRORLEVEL% EQU 0 goto :exit_script
if "%MAKER_ENV_VERBOSE%" neq "" echo on
set "Path=%MAKER_BIN%;%Path%"

:exit_script
if "%MAKER_ENV_VERBOSE%" neq "" echo on
cd /d "%_BMFL_START_DIR%"
set _BMFL_START_DIR=
call "%MAKER_BUILD%\validate_flex.bat" %_FLEX_VERSION% %MAKER_ENV_VERBOSE%