@echo off
call "%~dp0\maker_env.bat" %*
if "%WFVIEW_DIR%" equ "" call "%~dp0\clone_wfview.bat" %* --do_not_clone

set "WFVIEW_LIBS_DIR=%WFVIEW_DIR%\libs"
set "WFVIEW_LIBS_SRC_DIR=%WFVIEW_DIR%\libs_src"

rem wfview dependencies
rem https://wfview.org/developers/how-to-compile-with-windows/
rem ALL         (rtaudio, Eigen, portaudio, qcustomplot, hidapi, opus) https://www.wfview.org/public_builds/00_Dependencies/Developer/2025_libraries.zip
rem opus        (..\opus\include)      https://github.com/xiph/opus.git
rem hidapi      (..\hidapi\hidapi)     https://github.com/libusb/hidapi.git
rem portaudio   (..\portaudio\include) https://github.com/PortAudio/portaudio.git
rem qcustomplot (..\qcustomplot)       https://github.com/hankst69/qcustomplot.git https://www.qcustomplot.com/release/2.1.1/QCustomPlot-source.tar.gz
rem eigen       (..\eigen)             https://gitlab.com/libeigen/eigen.git
rem rtaudio     (..\rtaudio)           https://github.com/thestk/rtaudio.git
rem r8brain     (..\r8brain-free-src)
if not exist "%WFVIEW_DIR%" mkdir "%WFVIEW_DIR%"

set "WFVIEW_OPUS_DIR=%WFVIEW_LIBS_DIR%\opus"
set "WFVIEW_OPUS_SRC_DIR=%WFVIEW_LIBS_SRC_DIR%\opus"
call "%MAKER_SCRIPTS%\clone_in_folder.bat" "%WFVIEW_OPUS_SRC_DIR%" "https://github.com/xiph/opus.git" %MAKER_ENV_SILENT%

set "WFVIEW_RTAUDIO_DIR=%WFVIEW_LIBS_DIR%\rtaudio"
set "WFVIEW_RTAUDIO_SRC_DIR=%WFVIEW_LIBS_SRC_DIR%\rtaudio"
call "%MAKER_SCRIPTS%\clone_in_folder.bat" "%WFVIEW_RTAUDIO_SRC_DIR%" "https://github.com/thestk/rtaudio.git" %MAKER_ENV_SILENT%

set "WFVIEW_EIGEN_DIR=%WFVIEW_LIBS_DIR%\eigen"
set "WFVIEW_EIGEN_SRC_DIR=%WFVIEW_LIBS_SRC_DIR%\eigen"
call "%MAKER_SCRIPTS%\clone_in_folder.bat" "%WFVIEW_EIGEN_SRC_DIR%" "https://gitlab.com/libeigen/eigen.git" %MAKER_ENV_SILENT%

set "WFVIEW_PORTAUDIO_DIR=%WFVIEW_LIBS_DIR%\portaudio"
set "WFVIEW_PORTAUDIO_SRC_DIR=%WFVIEW_LIBS_SRC_DIR%\portaudio"
call "%MAKER_SCRIPTS%\clone_in_folder.bat" "%WFVIEW_PORTAUDIO_SRC_DIR%" "https://github.com/PortAudio/portaudio.git" %MAKER_ENV_SILENT%

set "WFVIEW_QCUSTOMPLOT_DIR=%WFVIEW_LIBS_DIR%\qcustomplot"
set "WFVIEW_QCUSTOMPLOT_SRC_DIR=%WFVIEW_LIBS_SRC_DIR%\qcustomplot"
call "%MAKER_SCRIPTS%\clone_in_folder.bat" "%WFVIEW_QCUSTOMPLOT_SRC_DIR%" "https://github.com/hankst69/qcustomplot.git" %MAKER_ENV_SILENT%

set "WFVIEW_HIDAPI_DIR=%WFVIEW_LIBS_DIR%\hidapi"
set "WFVIEW_HIDAPI_SRC_DIR=%WFVIEW_LIBS_SRC_DIR%\hidapi"
call "%MAKER_SCRIPTS%\clone_in_folder.bat" "%WFVIEW_HIDAPI_SRC_DIR%" "https://github.com/libusb/hidapi.git" %MAKER_ENV_SILENT%

if "%MAKER_ENV_VERBOSE%" neq "" set WFVIEW_
cd /d "%WFVIEW_LIBS_SRC_DIR%"
