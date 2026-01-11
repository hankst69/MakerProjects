@rem https://github.com/facebook/zstd
@echo off
call "%~dp0\maker_env.bat" %*

set "_ZS_VERSION=%MAKER_ENV_VERSION%"
set "_ZS_DIR=%MAKER_TOOLS%\ZStd"
set "_ZS_SOURCES_DIR=%_ZS_DIR%\zstd_sources%_ZS_VERSION%"

call "%MAKER_SCRIPTS%\clone_in_folder.bat" "%_ZS_SOURCES_DIR%" "https://github.com/facebook/zstd" --switchBranch release  --changeDir
