@rem "https://github.com/hankst69/fygen"
@rem "https://github.com/mattwach/fygen"
@echo off
call "%~dp0\maker_env.bat"

rem set "_FYGEN_DIR=%MAKER_PROJECTS%\mkr\AWGControl\fygen"
set "_FYGEN_DIR=%MAKER_PROJECTS%\AWGControl\fygen"

call "%MAKER_ENV_CORE%\clone_in_folder.bat" "%_FYGEN_DIR%" "https://github.com/hankst69/fygen.git" --changeDir
