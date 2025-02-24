@rem >winget show --id GnuWin32.Bison  &rem bison-2.4.1
@rem >choco info winflexbison          &rem bison-2.7.0 flex-2.6.3
@rem >choco info winflexbison3         &rem bison-3.7.4 flex-2.6.4
@echo off
set "_BMBS_START_DIR=%cd%"

call "%~dp0\maker_env.bat" %*
rem if "%MAKER_ENV_VERBOSE%" neq "" echo on

rem init with command line arguments
set "_BISON_VERSION=%MAKER_ENV_VERSION%"
set "_BISON_BUILD_TYPE=%MAKER_ENV_BUILDTYPE%"
set "_BISON_TGT_ARCH=%MAKER_ENV_ARCHITECTURE%"

rem apply defaults
if "%_BISON_VERSION%"    equ "" set _BISON_VERSION=2.4.1
rem if "%_BISON_VERSION%"    equ "" set _BISON_VERSION=2.7.0
rem if "%_BISON_BUILD_TYPE%" equ "" set _BISON_BUILD_TYPE=Release
rem set "_BISON_TGT_ARCH=x64"

rem take shortcut if possible
set ERRORLEVEL=
call "%MAKER_BUILD%\validate_bison.bat" %_BISON_VERSION% 1>nul 2>nul
if %ERRORLEVEL% EQU 0 goto :exit_script

set "_BISON_DIR=%MAKER_TOOLS%\Bison"
set "_BISON_BIN_DIR=%_BISON_DIR%\bison-%_BISON_VERSION%"

if "%MAKER_ENV_VERBOSE%" neq "" set _BISON_BIN_DIR

rem install/build...
rem
rem a) install using predownloaded zip files:
rem
if exist "%_BISON_BIN_DIR%\bin\bison.exe" goto :test_bison_path
rem unzip bison into %_BISON_DIR%
if not exist "%_BISON_BIN_DIR%" mkdir "%_BISON_BIN_DIR%"
pushd "%_BISON_BIN_DIR%"
call 7z x -y "%MAKER_TOOLS%\packages\bison-2.4.1-dep.zip" 1>NUL
call 7z x -y "%MAKER_TOOLS%\packages\bison-2.4.1-lib.zip" 1>NUL
call 7z x -y "%MAKER_TOOLS%\packages\bison-2.4.1-bin.zip" 1>NUL
rem call 7z x -y "%MAKER_TOOLS%\packages\bison-2.4.1-src.zip" 1>NUL
popd
if not exist "%_BISON_BIN_DIR%\bin\bison.exe" (
  echo. error: install BISON failed
  goto :exit_script
)
:test_bison_path
call "%MAKER_BUILD%\validate_bison.bat" %_BISON_VERSION% 1>nul 2>nul
if %ERRORLEVEL% neq 0 set "PATH=%_BISON_BIN_DIR%\bin;%PATH%"
goto :exit_script
rem
rem b) install using winget:
rem
rem call winget install --id GnuWin32.Bison
rem       -> goto :exit_script
rem       -> goto :test_bison_succes
rem
rem c) install using choco:
set "_BISON_BIN_DIR=%MAKER_BIN%"
call "%MAKER_BUILD%\ensure_choco.bat"
if %ERRORLEVEL% NEQ 0 (
  echo error: CHOCO is not available
  goto :exit_script
)
set "_CHOCO_BIN_BIN=%_CHOCO_BIN%\bin"
if exist "%_CHOCO_BIN_BIN%\win_bison.exe" goto :win_bison_installed
call choco install winflexbison --yes --force
if not exist "%_CHOCO_BIN_BIN%\win_bison.exe" (
  echo. error: install BISON failed
  goto :exit_script
)
:win_bison_installed
echo @call "%_CHOCO_BIN_BIN%\win_bison.exe" %%* >"%MAKER_BIN%\bison.bat"
echo @call "%_CHOCO_BIN_BIN%\win_flex.exe" %%* >"%MAKER_BIN%\flex.bat"
:test_win_bison_path
call "%MAKER_BUILD%\validate_bison.bat" %_BISON_VERSION% 1>nul 2>nul
if %ERRORLEVEL% neq 0 set "Path=%MAKER_BIN%;%Path%"

:exit_script
cd /d "%_BMBS_START_DIR%"
set _BMBS_START_DIR=
call "%MAKER_BUILD%\validate_bison.bat" %_BISON_VERSION% %MAKER_ENV_VERBOSE%
