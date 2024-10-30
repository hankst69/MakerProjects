@echo off
set "_ATC_CURRENT_DIR=%cd%"
set "_ATC_SCRIPT_ROOT=%~dp0"
call "%_ATC_SCRIPT_ROOT%clone_llvm.bat"
call "%_ATC_SCRIPT_ROOT%clone_emsdk.bat"
call "%_ATC_SCRIPT_ROOT%clone_choco.bat"
call "%_ATC_SCRIPT_ROOT%clone_qt.bat"
call "%_ATC_SCRIPT_ROOT%clone_vesc.bat"
cd /d "%_ATC_CURRENT_DIR%"
set _ATC_SCRIPT_ROOT=
set _ATC_CURRENT_DIR=