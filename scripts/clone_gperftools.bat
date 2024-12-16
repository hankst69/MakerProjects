@rem https://github.com/gperftools/gperftools
@echo off
call "%~dp0\maker_env.bat"

set _GPT_VERSION=
if "%~1" neq "" set "_GPT_VERSION=%~1"

set "_GPT_DIR=%MAKER_TOOLS%\GPerfTools"
set "_GPT_SOURCES_DIR=%_GPT_DIR%\source%_GPT_VERSION%\"

rem --- cloning GPerfTools
echo GPERFTOOLS-CLONE %_GPT_VERSION%
call "%MAKER_SCRIPTS%\clone_in_folder.bat" "%_GPT_SOURCES_DIR%" "https://github.com/gperftools/gperftools"
pushd "%_GPT_SOURCES_DIR%"

echo GPERFTOOLS-CLONE %_GPT_VERSION% done

if "%_GPT_SOURCES_DIR%" neq "" cd /d "%_GPT_SOURCES_DIR%"
