@rem https://de.wikipedia.org/wiki/Chocolatey
@rem https://chocolatey.org/
@rem https://github.com/chocolatey/choco.git
@echo off
call "%~dp0\maker_env.bat"

set "_CHOCO_DIR=%MAKER_TOOLS%\Choco"

call "%MAKER_SCRIPTS%\clone_in_folder.bat" "%_CHOCO_DIR%" "https://github.com/chocolatey/choco.git" --changeDir %*
