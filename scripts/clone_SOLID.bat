@rem "https://github.com/hankst69/SOLID"
@echo off
call "%~dp0\maker_env.bat"

set "_SOLID_DIR=%MAKER_PROJECTS_DOTNET%\SOLID"

call "%MAKER_SCRIPTS%\clone_in_folder.bat" "%_SOLID_DIR%" "https://github.com/hankst69/SOLID.git" --changeDir
