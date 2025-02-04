@rem "https://github.com/hankst69/IPTools"
@echo off
call "%~dp0\maker_env.bat"

set "_IPTOOLS_DIR=%MAKER_PROJECTS_DOTNET%\IPTools"

call "%MAKER_SCRIPTS%\clone_in_folder.bat" "%_IPTOOLS_DIR%" "https://github.com/hankst69/IPTools.git" --changeDir
