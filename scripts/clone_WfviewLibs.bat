@echo off
call "%~dp0\maker_env.bat" %*
if "%WFVIEW_DIR%" equ "" call "%~dp0\clone_wfview.bat" %* --do_not_clone

set "WFVIEW_LIBS_DIR=%WFVIEW_DIR%\libs"
set "WFVIEW_LIBS_SRC_DIR=%WFVIEW_DIR%\libs_src"

rem wfview dependencies
rem https://wfview.org/developers/how-to-compile-with-windows/
rem ALL         (rtaudio, Eigen, portaudio, qcustomplot, hidapi, opus) https://www.wfview.org/public_builds/00_Dependencies/Developer/2025_libraries.zip
rem
rem opus        (..\opus\include)      https://github.com/xiph/opus
rem hidapi      (..\hidapi\hidapi)     https://github.com/libusb/hidapi
rem portaudio   (..\portaudio\include) https://github.com/PortAudio/portaudio
rem qcustomplot (..\qcustomplot)       https://www.qcustomplot.com/release/2.1.1/QCustomPlot-source.tar.gz
rem                                    https://github.com/hankst69/qcustomplot
rem eigen       (..\eigen)             https://gitlab.com/libeigen/eigen
rem rtaudio     (..\rtaudio)           https://github.com/thestk/rtaudio
rem libsndfile  (..\libsndfile)        https://github.com/libsndfile/libsndfile
rem anr         (..\anr)               https://github.com/tals/audacity-noise-reduction (tree master -> sub folder noisereduction)
rem                                    https://github.com/hankst69/audacity-noise-reduction
rem adpcm-xq    (..\adpcm)             https://github.com/dbry/adpcm-xq
rem
rem r8brain     (..\r8brain-free-src)  https://github.com/avaneev/r8brain-free-src
rem LibFT4222   (..\libft4222)         https://ftdichip.com/software-examples/ft4222h-software-examples/
if not exist "%WFVIEW_DIR%" mkdir "%WFVIEW_DIR%"

set "WFVIEW_OPUS_DIR=%WFVIEW_LIBS_DIR%\opus"
set "WFVIEW_OPUS_SRC_DIR=%WFVIEW_LIBS_SRC_DIR%\opus"
call "%MAKER_ENV_CORE%\clone_in_folder.bat" "%WFVIEW_OPUS_SRC_DIR%" "https://github.com/xiph/opus.git" %MAKER_MSG_SILENT%

set "WFVIEW_RTAUDIO_DIR=%WFVIEW_LIBS_DIR%\rtaudio"
set "WFVIEW_RTAUDIO_SRC_DIR=%WFVIEW_LIBS_SRC_DIR%\rtaudio"
call "%MAKER_ENV_CORE%\clone_in_folder.bat" "%WFVIEW_RTAUDIO_SRC_DIR%" "https://github.com/thestk/rtaudio.git" %MAKER_MSG_SILENT%

set "WFVIEW_EIGEN_DIR=%WFVIEW_LIBS_DIR%\eigen"
set "WFVIEW_EIGEN_SRC_DIR=%WFVIEW_LIBS_SRC_DIR%\eigen"
call "%MAKER_ENV_CORE%\clone_in_folder.bat" "%WFVIEW_EIGEN_SRC_DIR%" "https://gitlab.com/libeigen/eigen.git" %MAKER_MSG_SILENT%

set "WFVIEW_PORTAUDIO_DIR=%WFVIEW_LIBS_DIR%\portaudio"
set "WFVIEW_PORTAUDIO_SRC_DIR=%WFVIEW_LIBS_SRC_DIR%\portaudio"
call "%MAKER_ENV_CORE%\clone_in_folder.bat" "%WFVIEW_PORTAUDIO_SRC_DIR%" "https://github.com/PortAudio/portaudio.git" %MAKER_MSG_SILENT%

set "WFVIEW_QCUSTOMPLOT_DIR=%WFVIEW_LIBS_DIR%\qcustomplot"
set "WFVIEW_QCUSTOMPLOT_SRC_DIR=%WFVIEW_LIBS_SRC_DIR%\qcustomplot"
call "%MAKER_ENV_CORE%\clone_in_folder.bat" "%WFVIEW_QCUSTOMPLOT_SRC_DIR%" "https://github.com/hankst69/qcustomplot.git" %MAKER_MSG_SILENT%

set "WFVIEW_HIDAPI_DIR=%WFVIEW_LIBS_DIR%\hidapi"
set "WFVIEW_HIDAPI_SRC_DIR=%WFVIEW_LIBS_SRC_DIR%\hidapi"
call "%MAKER_ENV_CORE%\clone_in_folder.bat" "%WFVIEW_HIDAPI_SRC_DIR%" "https://github.com/libusb/hidapi.git" %MAKER_MSG_SILENT%

set "WFVIEW_LIBSNDFILE_DIR=%WFVIEW_LIBS_DIR%\libsndfile"
set "WFVIEW_LIBSNDFILE_SRC_DIR=%WFVIEW_LIBS_SRC_DIR%\libsndfile"
call "%MAKER_ENV_CORE%\clone_in_folder.bat" "%WFVIEW_LIBSNDFILE_SRC_DIR%" "https://github.com/libsndfile/libsndfile.git" %MAKER_MSG_SILENT%

set "WFVIEW_ANR_DIR=%WFVIEW_LIBS_DIR%\anr"
set "WFVIEW_ANR_SRC_DIR=%WFVIEW_LIBS_SRC_DIR%\anr"
call "%MAKER_ENV_CORE%\clone_in_folder.bat" "%WFVIEW_ANR_SRC_DIR%" "https://github.com/hankst69/audacity-noise-reduction.git" %MAKER_MSG_SILENT% --switchBranch fixes/cmake

set "WFVIEW_ADPCM_DIR=%WFVIEW_LIBS_DIR%\adpcm"
set "WFVIEW_ADPCM_SRC_DIR=%WFVIEW_LIBS_SRC_DIR%\adpcm"
call "%MAKER_ENV_CORE%\clone_in_folder.bat" "%WFVIEW_ADPCM_SRC_DIR%" "https://github.com/dbry/adpcm-xq" %MAKER_MSG_SILENT%

set "WFVIEW_R8BRAIN_DIR=%WFVIEW_LIBS_DIR%\r8brain-free-src"
set "WFVIEW_R8BRAIN_SRC_DIR=%WFVIEW_LIBS_SRC_DIR%\r8brain-free-src"
call "%MAKER_ENV_CORE%\clone_in_folder.bat" "%WFVIEW_R8BRAIN_SRC_DIR%" "https://github.com/avaneev/r8brain-free-src.git" %MAKER_MSG_SILENT%

set "WFVIEW_LIBFT4222_DIR=%WFVIEW_LIBS_DIR%\libft4222"
set "WFVIEW_LIBFT4222_SRC_DIR=%WFVIEW_LIBS_SRC_DIR%\libft4222"
set "WFVIEW_LIBFT4222_SRC_DIR_WINDOWS=%WFVIEW_LIBFT4222_SRC_DIR%\WINDOWS"
set "WFVIEW_LIBFT4222_SRC_DIR_LINUX=%WFVIEW_LIBFT4222_SRC_DIR%\LINUX"

set "WFVIEW_LIBFT4222_URI_WINDOWS=https://ftdichip.com/wp-content/uploads/2025/06/LibFT4222-v1.4.8.zip"
set "WFVIEW_LIBFT4222_URI_LINUX=https://ftdichip.com/wp-content/uploads/2025/04/libft4222-linux-1.4.4.232.zip"
call "%MAKER_ENV_CORE%\download_in_folder.bat" "%WFVIEW_LIBFT4222_SRC_DIR_WINDOWS%" "%WFVIEW_LIBFT4222_URI_WINDOWS%" %MAKER_MSG_SILENT%
call "%MAKER_ENV_CORE%\download_in_folder.bat" "%WFVIEW_LIBFT4222_SRC_DIR_LINUX%" "%WFVIEW_LIBFT4222_URI_LINUX%" %MAKER_MSG_SILENT%

rem curl -o pthreads4w-code-v3.0.0.zip https://sourceforge.net/projects/pthreads4w/files/latest/download/pthreads4w-code-v3.0.0.zip
set "WFVIEW_PTHREADS_SRC_URI_WINDOWS=https://sourceforge.net/projects/pthreads4w/files/latest/download/pthreads4w-code-v3.0.0.zip"
set "WFVIEW_PTHREADS_DWNLD_DIR=%WFVIEW_LIBS_SRC_DIR%\pthreads_dwnld"
set "WFVIEW_PTHREADS_DIR=%WFVIEW_LIBS_DIR%\pthreads"
set "WFVIEW_PTHREADS_SRC_DIR=%WFVIEW_LIBS_SRC_DIR%\pthreads"
call "%MAKER_ENV_CORE%\download_in_folder.bat" "%WFVIEW_PTHREADS_DWNLD_DIR%" "%WFVIEW_PTHREADS_SRC_URI_WINDOWS%" %MAKER_MSG_SILENT%
call "%MAKER_ENV_CORE%\extract_in_folder.bat" "%WFVIEW_PTHREADS_SRC_DIR%" "%WFVIEW_PTHREADS_DWNLD_DIR%" %MAKER_MSG_SILENT%


if "%MAKER_MSG_VERBOSE%" neq "" set WFVIEW_
cd /d "%WFVIEW_LIBS_SRC_DIR%"
