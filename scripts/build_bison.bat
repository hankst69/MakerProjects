@rem >winget show --id GnuWin32.Bison  &rem bison-2.4.1
@rem >choco info winflexbison          &rem bison-2.7.0 flex-2.6.3
@rem >choco info winflexbison3         &rem bison-3.7.4 flex-2.6.4
@echo off
set "_BMBS_START_DIR=%cd%"

call "%~dp0\maker_env.bat" %*
if "%MAKER_ENV_VERBOSE%" neq "" echo on

set "_BISON_VERSION=%MAKER_ENV_VERSION%"
set "_BISON_BUILD_TYPE=%MAKER_ENV_BUILDTYPE%"
set "_BISON_TGT_ARCH=%MAKER_ENV_ARCHITECTURE%"

rem apply defaults
rem if "%_BISON_VERSION%"    equ "" set _BISON_VERSION=2.4.1
if "%_BISON_VERSION%"    equ "" set _BISON_VERSION=2.7.0
rem if "%_BISON_BUILD_TYPE%" equ "" set _BISON_BUILD_TYPE=Release
rem set "_BISON_TGT_ARCH=x64"

set ERRORLEVEL=
call "%MAKER_BUILD%\validate_bison.bat" %_BISON_VERSION% 1>nul 2>nul
if %ERRORLEVEL% EQU 0 goto :exit_script
if "%MAKER_ENV_VERBOSE%" neq "" echo on

rem install/build bison
rem a) install using predownloaded zip files:
rem set "_BISON_DIR=%MAKER_TOOLS%\Bison"
rem set "_BISON_BIN_DIR=%_BISON_DIR%\bison-%_BISON_VERSION%"
rem if not exist "%_BISON_BIN_DIR%" mkdir "%_BISON_BIN_DIR%"
rem if exist "%_BISON_BIN_DIR%\bin\bison.exe" goto :test_bison_succes
rem todo: unzip bison into %_BISON_DIR%
rem       -> goto :exit_script
rem       -> goto :test_bison_succes
rem
rem
rem b) install using winget:
rem call winget install --id GnuWin32.Bison
rem       -> goto :exit_script
rem       -> goto :test_bison_succes
rem
rem c) install using choco:
set "_BISON_BIN_DIR=%MAKER_BIN%"
if not exist "%MAKER_BIN%\.choco\bin\win_bison.exe" (
  call "%MAKER_BUILD%\ensure_choco.bat"
  if %ERRORLEVEL% NEQ 0 (
    echo error: CHOCO is not available
    goto :exit_script
  )
  call choco install winflexbison -y --force
    if not exist "%_CHOCO_BIN%\bin\bison.exe" (
      echo. error: install BISON failed
      goto :exit_script
    )
  )
)
if not exist "%MAKER_BIN%\.choco\bin\win_bison.exe" goto :exit_script
echo @call "%%MAKER_BIN%%\.choco\bin\win_bison.exe" %%* >"%MAKER_BIN%\bison.bat"
echo @call "%%MAKER_BIN%%\.choco\bin\win_flex.exe" %%* >"%MAKER_BIN%\flex.bat"
goto :test_bison_succes


:test_bison_succes
call "%MAKER_BUILD%\validate_bison.bat" %_BISON_VERSION% 1>nul 2>nul
if %ERRORLEVEL% EQU 0 goto :exit_script
if "%MAKER_ENV_VERBOSE%" neq "" echo on
set "Path=%MAKER_BIN%;%Path%"

:exit_script
if "%MAKER_ENV_VERBOSE%" neq "" echo on
cd /d "%_BMBS_START_DIR%"
set _BMBS_START_DIR=
call "%MAKER_BUILD%\validate_bison.bat" %_BISON_VERSION% %MAKER_ENV_VERBOSE%
