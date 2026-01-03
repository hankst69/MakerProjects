@rem https://gitlab.com/eliggett/wfview.git
@rem https://gitlab.com/hankst69/wfview.git
@echo off
call "%~dp0\maker_env.bat" %*

rem wfview dependencies
rem ALL         (rtaudio, Eigen, portaudio, qcustomplot, hidapi, opus) https://www.wfview.org/public_builds/00_Dependencies/Developer/2025_libraries.zip
rem opus        (..\opus\include)      https://github.com/xiph/opus.git
rem hidapi      (..\hidapi\hidapi)
rem portaudio   (..\portaudio\include) https://github.com/PortAudio/portaudio.git
rem qcustomplot (..\qcustomplot)       https://github.com/hankst69/qcustomplot.git https://www.qcustomplot.com/release/2.1.1/QCustomPlot-source.tar.gz
rem eigen       (..\eigen)             https://gitlab.com/libeigen/eigen.git
rem rtaudio     (..\rtaudio)           https://github.com/thestk/rtaudio.git
rem r8brain     (..\r8brain-free-src)
rem 

call "%MAKER_SCRIPTS%\set_version_env" "WFVIEW" "%MAKER_ENV_VERSION%"
set "WFVIEW_BASE_DIR=wfview"
set "WFVIEW_DIR=%MAKER_PROJECTS%\wfview"
set "WFVIEW_SCR_DIR=%WFVIEW_DIR%\%WFVIEW_BASE_DIR%_source%WFVIEW_VERSION%"

set "WFVIEW_SILENT_CLONE_MODE=%MAKER_ENV_SILENT%"
set "WFVIEW_CHECKOUT_BRANCH="
if "%WFVIEW_VERSION_MAJOR%.%VERSION_MINOR%" equ "2.20" set "WFVIEW_CHECKOUT_BRANCH=--switchBranch v2.20-dev"

if "%MAKER_ENV_VERBOSE%" neq "" set WFVIEW_

if not exist "%WFVIEW_DIR%" mkdir "%WFVIEW_DIR%"
cd /d "%WFVIEW_DIR%"
call "%MAKER_SCRIPTS%\clone_in_folder.bat" "%WFVIEW_SCR_DIR%" "https://gitlab.com/hankst69/wfview.git" %WFVIEW_CHECKOUT_BRANCH% %WFVIEW_SILENT_CLONE_MODE%

set "WFVIEW_OPUS_SCR_DIR=%WFVIEW_DIR%\opus"
call "%MAKER_SCRIPTS%\clone_in_folder.bat" "%WFVIEW_OPUS_SCR_DIR%" "https://github.com/xiph/opus.git" %WFVIEW_SILENT_CLONE_MODE%
set "WFVIEW_RTAUDIO_SCR_DIR=%WFVIEW_DIR%\rtaudio"
call "%MAKER_SCRIPTS%\clone_in_folder.bat" "%WFVIEW_RTAUDIO_SCR_DIR%" "https://github.com/thestk/rtaudio.git" %WFVIEW_SILENT_CLONE_MODE%
set "WFVIEW_EIGEN_SCR_DIR=%WFVIEW_DIR%\eigen"
call "%MAKER_SCRIPTS%\clone_in_folder.bat" "%WFVIEW_EIGEN_SCR_DIR%" "https://gitlab.com/libeigen/eigen.git" %WFVIEW_SILENT_CLONE_MODE%
set "WFVIEW_PORTAUDIO_SCR_DIR=%WFVIEW_DIR%\portaudio"
call "%MAKER_SCRIPTS%\clone_in_folder.bat" "%WFVIEW_PORTAUDIO_SCR_DIR%" "https://github.com/PortAudio/portaudio.git" %WFVIEW_SILENT_CLONE_MODE%
set "WFVIEW_QCUSTOMPLOT_SCR_DIR=%WFVIEW_DIR%\qcustomplot"
call "%MAKER_SCRIPTS%\clone_in_folder.bat" "%WFVIEW_QCUSTOMPLOT_SCR_DIR%" "https://github.com/hankst69/qcustomplot.git" %WFVIEW_SILENT_CLONE_MODE%

