@rem https://github.com/KDAB/GammaRay.git
@rem https://github.com/KDAB/GammaRay/blob/master/INSTALL.md
@echo off
call "%~dp0\maker_env.bat" %*

set "_GR_VERSION=%MAKER_ENV_VERSION%"
set "_GR_SRC_NAME=GammaRay_sources"

rem apply explicite clone-folder-name:
if "%MAKER_ENV_UNKNOWN_ARG_1%" neq "" set "_GR_SRC_NAME=%MAKER_ENV_UNKNOWN_ARG_1%"

rem apply version default:
rem if "%_GR_VERSION%" equ "" set _GR_VERSION=3.1

rem define folders:
set "_GR_DIR=%MAKER_TOOLS%\Qt"
set "_GR_SOURCES_DIR=%_GR_DIR%\%_GR_SRC_NAME%%_GR_VERSION%"

set _GR_SILENT_CLONE_MODE=
if "%MAKER_ENV_UNKNOWN_SWITCHES%" equ "" goto :gr_clone
for %%i in (%MAKER_ENV_UNKNOWN_SWITCHES%) do if /I "%%~i" equ "--silent"    set _GR_SILENT_CLONE_MODE=--silent


:gr_clone
rem print debug info:
if "%MAKER_ENV_VERBOSE%" neq "" set _GR


rem --- cloning GarmmaRay
if "%_GR_VERSION%" neq "" goto :gr_clone_version

:gr_clone_latest
if "%_GR_SILENT_CLONE_MODE%" equ "" echo GAMMARAY-CLONE %_GR_VERSION%
call "%MAKER_SCRIPTS%\clone_in_folder.bat" "%_GR_SOURCES_DIR%" "https://github.com/KDAB/GammaRay.git" --switchBranch master %_GR_SILENT_CLONE_MODE%
goto :gr_clone_done

:gr_clone_version
if "%_GR_SILENT_CLONE_MODE%" equ "" echo GAMMARAY-CLONE %_GR_VERSION%
call "%MAKER_SCRIPTS%\clone_in_folder.bat" "%_GR_SOURCES_DIR%" "https://github.com/KDAB/GammaRay.git" --switchBranch %_GR_VERSION% %_GR_SILENT_CLONE_MODE%
goto :gr_clone_done

:gr_clone_done
echo GAMMARAY-CLONE %_GR_VERSION% done

cd "%_GR_SOURCES_DIR%"
