@rem "https://github.com/hankst69/IPTools"
@echo off
call "%~dp0\maker_env.bat"

rem set "_IPTOOLS_DIR=%MAKER_PROJECTS%\CSharp\IPTools"
rem set "_IPTOOLS_DIR=%MAKER_PROJECTS%\cs\IPTools"
set "_IPTOOLS_DIR=%MAKER_PROJECTS%\Net\IPTools"

call "%MAKER_SCRIPTS%\clone_in_folder.bat" "%_IPTOOLS_DIR%" "https://github.com/hankst69/IPTools.git" --changeDir
