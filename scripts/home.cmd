@echo off
set "_CURRENT_DIR=%CD%"
call home.bat
if "%_CURRENT_DIR%" neq "%CD%" goto :EOF
cd /d "%~dp0.."