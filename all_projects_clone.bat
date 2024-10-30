@echo off
set "_APC_CURRENT_DIR=%cd%"
set "_APC_SCRIPT_ROOT=%~dp0"

set "_ALL_PROJECTS=espBode fygen victron-guiv2 Python html5_rtsp_player UserScripts SOLID IPTools"

echo ----------------------------------------------------------------------
echo about to clone:
echo ----------------------------------------------------------------------
echo.
call :for_each --long "%_ALL_PROJECTS%"
echo.
echo ----------------------------------------------------------------------
echo cloning
echo ----------------------------------------------------------------------
echo.
call :for_each --clone "%_ALL_PROJECTS%"
echo.
echo ----------------------------------------------------------------------
echo call one of the clone scripts again to see state and change directory:
echo ----------------------------------------------------------------------
echo.
call :for_each --short "%_ALL_PROJECTS%"
cd /d "%_APC_CURRENT_DIR%"
set _APC_CURRENT_DIR=
set _APC_SCRIPT_ROOT=
set _ALL_PROJECTS=
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
  if "%%~p" neq "" if exist "%_APC_SCRIPT_ROOT%clone_%%~p.bat" (
    if /I "%~1" equ "--short" echo clone_%%~p
    if /I "%~1" equ "--long"  echo "%_APC_SCRIPT_ROOT%clone_%%~p.bat"
    if /I "%~1" equ "--clone" call "%_APC_SCRIPT_ROOT%clone_%%~p.bat"
  )
  if "%%~p" neq "" if not exist "%_APC_SCRIPT_ROOT%clone_%%~p.bat" (
    echo warning: clone script '%_APC_SCRIPT_ROOT%clone_%%~p.bat' does not exist
  )
  if "%%~q" neq "" call :for_each "%~1" "%%~q"
)
goto :EOF
