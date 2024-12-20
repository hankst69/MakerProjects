@echo off
set "_MULTICLONE_CURRENT_DIR=%cd%"
call "%~dp0\maker_env.bat" %*

set "_MULTICLONE_PROJECTS=%MAKER_ENV_ALL_ARGS%"

echo ----------------------------------------------------------------------
echo about to clone:
echo ----------------------------------------------------------------------
call :for_each --long "%_MULTICLONE_PROJECTS%"
echo.
echo ----------------------------------------------------------------------
echo cloning
echo ----------------------------------------------------------------------
echo.
call :for_each --clone "%_MULTICLONE_PROJECTS%"
echo.
echo ----------------------------------------------------------------------
echo call one of the clone scripts again to see state and change directory:
echo ----------------------------------------------------------------------
call :for_each --short "%_MULTICLONE_PROJECTS%"
cd /d "%_MULTICLONE_CURRENT_DIR%"
call "%MAKER_SCRIPTS%\clear_temp_envs.bat"
set _MULTICLONE_CURRENT_DIR=
set _MULTICLONE_PROJECTS=
goto :EOF


:for_each
if "%~1" equ "" goto :EOF
if /I "%~1" equ "--short" goto :for_each_next
if /I "%~1" equ "--long" goto :for_each_next
if /I "%~1" equ "--clone" goto :for_each_next
echo error: unknown argument '%~1'
goto :EOF
:for_each_next
if "%~2" equ "" goto :EOF
for /f "tokens=1,* delims= " %%p in ("%~2") do (
  if "%%~p" neq "" if exist "%MAKER_BUILD%\clone_%%~p.bat" (
    if /I "%~1" equ "--short" echo clone %%~p
    if /I "%~1" equ "--long"  echo "%MAKER_BUILD%\clone_%%~p.bat"
    if /I "%~1" equ "--clone" call "%MAKER_BUILD%\clone_%%~p.bat"
  )
  if "%%~p" neq "" if not exist "%MAKER_BUILD%\clone_%%~p.bat" (
    echo warning: clone script '%MAKER_BUILD%\clone_%%~p.bat' does not exist
  )
  if "%%~q" neq "" call :for_each "%~1" "%%~q"
)
goto :EOF
