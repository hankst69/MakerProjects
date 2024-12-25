@rem https://github.com/vedderb/bldc?tab=readme-ov-file#on-all-platforms
@rem >choco install make
@rem >winget show --id ezwinports.make
@rem >winget install --id ezwinports.make
@echo off
set "_BMK_START_DIR=%cd%"

call "%~dp0\maker_env.bat"
if "%MAKER_ENV_VERBOSE%" neq "" echo on


call "%MAKER_BUILD%\validate_make.bat" 1>nul
if %ERRORLEVEL% EQU 0 goto :test_make_success

if exist "%MAKER_BIN%\make.bat" (
  rem deep test for correct version
  set _VERSION_NR=
  for /f "tokens=1,2,* delims= " %%i in ('call "%%MAKER_BIN%%\make.bat" --version') do if /I "%%i" equ "gnu" if /I "%%j" equ "make" set "_VERSION_NR=%%k"
  rem if "%_VERSION_NR%" neq "" echo MAKE already available
  if "%_VERSION_NR%" neq "" set "Path=%MAKER_BIN%;%Path%"
  if "%_VERSION_NR%" neq "" goto :test_make_success
)

call "%MAKER_BUILD%\ensure_choco.bat"
if %ERRORLEVEL% NEQ 0 (
  echo error: CHOCO is not available
  goto :exit_script
)
rem defines: _CHOCO_DIR
rem defines: _CHOCO_BIN
if not exist "%_CHOCO_BIN%\bin\make.exe" (
  call choco install make
  if not exist "%_CHOCO_BIN%\bin\make.exe" (
    echo. error: install MAKE failed
    goto :exit_script
  )
)

echo @call "%%_CHOCO_BIN%%\bin\make.exe" %%* >"%MAKER_BIN%\make.bat"

call "%MAKER_BUILD%\validate_make.bat" 1>nul
if %ERRORLEVEL% NEQ 0 set "Path=%MAKER_BIN%;%Path%"
call "%MAKER_BUILD%\validate_make.bat" 1>nul
if %ERRORLEVEL% NEQ 0 (
  echo error: installing MAKE failed
  goto :exit_script
)

:test_make_success
call "%MAKER_BUILD%\validate_make.bat"

:exit_script
cd /d "%_BMK_START_DIR%"
set _BMK_START_DIR=
