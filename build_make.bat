@echo off
pushd
rem https://github.com/vedderb/bldc?tab=readme-ov-file#on-all-platforms
set "_MAKER_ROOT=%~dp0"
set "_TOOLS_DIR=%_MAKER_ROOT%\.tools"


call which make.bat 1>nul 2>nul
if %ERRORLEVEL% EQU 0 (
  rem deep test for correct version
  set _VERSION_NR=
  for /f "tokens=1,2,* delims= " %%i in ('call make --version') do if /I "%%i" equ "gnu" if /I "%%j" equ "make" set "_VERSION_NR=%%k"
  rem if "%_VERSION_NR%" neq "" echo MAKE already available
  if "%_VERSION_NR%" neq "" goto :test_make_success
)

if exist "%_TOOLS_DIR%\make.bat" (
  rem deep test for correct version
  set _VERSION_NR=
  for /f "tokens=1,2,* delims= " %%i in ('call "%_TOOLS_DIR%\make.bat" --version') do if /I "%%i" equ "gnu" if /I "%%j" equ "make" set "_VERSION_NR=%%k"
  rem if "%_VERSION_NR%" neq "" echo MAKE already available
  if "%_VERSION_NR%" neq "" set "Path=%_TOOLS_DIR%;%Path%"
  if "%_VERSION_NR%" neq "" goto :test_make_success
)

call "%_MAKER_ROOT%\build_choco.bat"
rem defines: _CHOCO_DIR
rem defines: _TOOLS_CHOCO_DIR

if not exist "%_TOOLS_CHOCO_DIR%\bin\make.exe" (
  call choco install make
  if not exist "%_TOOLS_CHOCO_DIR%\bin\make.exe" (
    echo. error: install MAKE failed
    goto :exit_script
  )
)

echo @call "%%_TOOLS_CHOCO_DIR%%\bin\make.exe" %%* >"%_TOOLS_DIR%\make.bat"

call which make.bat 1>nul 2>nul
if %ERRORLEVEL% neq 0 set "Path=%_TOOLS_DIR%;%Path%"

call which make.bat 1>nul 2>nul
if %ERRORLEVEL% NEQ 0 (
  echo error: installing MAKE failed
  goto :exit_script
)

:test_make_success
set _VERSION_NR=
for /f "tokens=1,2,* delims= " %%i in ('call make --version') do if /I "%%j" equ "make" set "_VERSION_NR=%%k"
rem for /f "tokens=6,* delims= " %%i in ('"%_QT_CREATOR_ENV_DIR%\Scripts\make.bat" --version') do set "_VERSION_NR=%%j"
echo make %_VERSION_NR%
set _VERSION_NR=

:exit_script
popd