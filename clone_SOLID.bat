@rem "https://github.com/hankst69/SOLID"
@echo off
set "_MAKER_ROOT=%~dp0"
rem set "_SOLID_DIR=%_MAKER_ROOT%CSharp\SOLID"
rem set "_SOLID_DIR=%_MAKER_ROOT%projects\cs\SOLID"
set "_SOLID_DIR=%_MAKER_ROOT%projects\net\SOLID"

call "%_MAKER_ROOT%scripts\clone_in_folder.bat" "%_SOLID_DIR%" "https://github.com/hankst69/SOLID.git" --changeDir
