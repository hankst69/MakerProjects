@rem https://github.com/vedderb/bldc?tab=readme-ov-file#on-all-platforms
@echo off
call "%~dp0\maker_env.bat"
set "_BMK_START_DIR=%cd%"

call "%MAKER_SCRIPTS%\validate_make.bat" 1>nul
if %ERRORLEVEL% EQU 0 goto :test_make_success

if exist "%MAKER_BIN%\make.bat" (
  rem deep test for correct version
  set _VERSION_NR=
  for /f "tokens=1,2,* delims= " %%i in ('call "%%MAKER_BIN%%\make.bat" --version') do if /I "%%i" equ "gnu" if /I "%%j" equ "make" set "_VERSION_NR=%%k"
  rem if "%_VERSION_NR%" neq "" echo MAKE already available
  if "%_VERSION_NR%" neq "" set "Path=%MAKER_BIN%;%Path%"
  if "%_VERSION_NR%" neq "" goto :test_make_success
)

call "%MAKER_ROOT%\build_choco.bat"
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

call "%MAKER_SCRIPTS%\validate_make.bat" 1>nul
if %ERRORLEVEL% NEQ 0 set "Path=%MAKER_BIN%;%Path%"


call "%MAKER_SCRIPTS%\validate_make.bat" 1>nul
if %ERRORLEVEL% NEQ 0 (
  echo error: installing MAKE failed
  goto :exit_script
)

:test_make_success
call "%MAKER_SCRIPTS%\validate_make.bat"

:exit_script
cd /d "%_BMK_START_DIR%"
set _BMK_START_DIR=