@call "%~dp0\maker_env.bat"
@set "_OPERASESSIONS_DIR=%MAKER_TOOLS%\OperaSessions"
@call "%MAKER_SCRIPTS%\clone_in_folder.bat" "%_OPERASESSIONS_DIR%" "https://github.com/hankst69/OperaSessions.git" --changeDir
