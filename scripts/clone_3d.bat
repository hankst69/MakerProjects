@rem "https://github.com/hankst69/3D-Print.git"
@echo off
call "%~dp0\maker_env.bat"

rem we cannot use "%3DPRNT_DIR%" because: https://stackoverflow.com/questions/30109655/valid-batch-file-variable-names
set "_3DPRINT_DIR=%MAKER_ROOT%\3D-Print"

call "%MAKER_SCRIPTS%\clone_in_folder.bat" "%_3DPRINT_DIR%" "https://github.com/hankst69/3D-Print.git" --changeDir

rem set "3DPRINT_DIR=%_3DPRINT_DIR%"
rem set _3DPRINT_DIR=
