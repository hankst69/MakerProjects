@rem "https://github.com/hankst69/IPTools"
@echo off
set "_MAKER_ROOT=%~dp0"
rem set "_IPTOOLS_DIR=%_MAKER_ROOT%CSharp\IPTools"
rem set "_IPTOOLS_DIR=%_MAKER_ROOT%projects\cs\IPTools"
set "_IPTOOLS_DIR=%_MAKER_ROOT%projects\net\IPTools"

call "%_MAKER_ROOT%scripts\clone_in_folder.bat" "%_IPTOOLS_DIR%" "https://github.com/hankst69/IPTools.git" --changeDir
