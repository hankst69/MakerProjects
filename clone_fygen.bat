@rem "https://github.com/hankst69/fygen"
@rem "https://github.com/mattwach/fygen"
@echo off
set "_MAKER_ROOT=%~dp0"
rem set "_FYGEN_DIR=%_MAKER_ROOT%ProjectAWGControl\fygen"
rem set "_FYGEN_DIR=%_MAKER_ROOT%projects\AWGControl\fygen"
set "_FYGEN_DIR=%_MAKER_ROOT%projects\mkr\AWGControl\fygen"

call "%_MAKER_ROOT%scripts\clone_in_folder.bat" "%_FYGEN_DIR%" "https://github.com/hankst69/fygen.git" --changeDir
