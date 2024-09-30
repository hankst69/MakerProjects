@echo off
set "_MAKER_ROOT=%~dp0"
rem https://vesc-project.com/vesc_tool
rem https://vesc-project.com/node/309
rem https://github.com/vedderb/vesc_tool
rem http://github.com/vedderb/bldc

set "_VESC_DIR=%_MAKER_ROOT%VESC"
if not exist "%_VESC_DIR%" mkdir "%_VESC_DIR%"

set "_VESC_FW_DIR=%_VESC_DIR%\vesc_fw"
set "_VESC_TOOL_DIR=%_VESC_DIR%\vesc_tool"

call "%_MAKER_ROOT%\scripts\clone_in_folder.bat" "%_VESC_FW_DIR%" "http://github.com/vedderb/bldc"
call "%_MAKER_ROOT%\scripts\clone_in_folder.bat" "%_VESC_TOOL_DIR%" "https://github.com/vedderb/vesc_tool" --changeDir
