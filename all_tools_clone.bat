@echo off
set "_MAKER_ROOT=%~dp0"
call "%_MAKER_ROOT%clone_emsdk.bat"
call "%_MAKER_ROOT%clone_choco.bat"
call "%_MAKER_ROOT%clone_qt.bat"
call "%_MAKER_ROOT%clone_vesc.bat"
