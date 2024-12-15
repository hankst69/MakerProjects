@echo off
call "%~dp0\maker_env.bat"
call "%MAKER_SCRIPTS%\validate_gperf.bat" %* 1>nul 2>nul
if %ERRORLEVEL% EQU 0 echo GPERF %GPERF_VERSION% available &exit /b 0

set "_GP_BIN_DIR=%MAKER_TOOLS%\GPerf\gperf\bin"
set "_GP_TEST_OBJECT=%_GP_BIN_DIR%\tcmalloc_minimal.dll"

if not exist "%_GP_TEST_OBJECT%" call "%MAKER_ROOT%\build_gperf.bat" %*
if not exist "%_GP_TEST_OBJECT%" echo error: GPERF %* failed &exit /b 1

if exist "%_GP_TEST_OBJECT%" set "PATH=%PATH%;%_GP_BIN_DIR%"

"%MAKER_SCRIPTS%\validate_gperf.bat" %*
