@rem "https://github.com/hankst69/3D-Print.git"
@echo off
call "%~dp0\maker_env.bat"

set "3DPRINT_DIR=%MAKER_ROOT%\3D-Print"

call "%MAKER_SCRIPTS%\clone_in_folder.bat" "%3DPRINT_DIR%" "https://github.com/hankst69/3D-Print.git" --changeDir
