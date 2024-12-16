@rem https://www.gnu.org/software/gperf/gperf.html
@rem https://github.com/rurban/gperf
@rem https://github.com/GerHobbelt/gperf
@rem https://github.com/hankst69/gperf
@echo off
call "%~dp0\maker_env.bat"

set "_GP_DIR=%MAKER_TOOLS%\GPerf"

set _GP_VERSION=
if "%~1" neq "" set "_GP_VERSION=%~1"
set "_GP_SOURCES_DIR=%_GP_DIR%\gperf_sources%_GP_VERSION%\"

call "%MAKER_SCRIPTS%\clone_in_folder.bat" "%_GP_SOURCES_DIR%" "https://github.com/hankst69/gperf.git" --switchBranch master  --changeDir
