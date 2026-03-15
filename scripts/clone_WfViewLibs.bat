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
rem r8brain     (..\r8brain-free-src)  https://github.com/avaneev/r8brain-free-src.git
rem LibFT4222   (..\libft4222)         https://ftdichip.com/wp-content/uploads/2025/06/LibFT4222-v1.4.8.zip https://ftdichip.com/software-examples/ft4222h-software-examples/
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

set "WFVIEW_R8BRAIN_DIR=%WFVIEW_LIBS_DIR%\r8brain-free-src"
set "WFVIEW_R8BRAIN_SRC_DIR=%WFVIEW_LIBS_SRC_DIR%\r8brain-free-src"
call "%MAKER_SCRIPTS%\clone_in_folder.bat" "%WFVIEW_R8BRAIN_SRC_DIR%" "https://github.com/avaneev/r8brain-free-src.git" %MAKER_ENV_SILENT%

set "WFVIEW_LIBFT4222_DIR=%WFVIEW_LIBS_DIR%\libft4222"
set "WFVIEW_LIBFT4222_SRC_DIR=%WFVIEW_LIBS_SRC_DIR%\libft4222"
set "WFVIEW_LIBFT4222_URI=https://ftdichip.com/wp-content/uploads/2025/06/LibFT4222-v1.4.8.zip"
set "WFVIEW_LIBFT4222_VERSION=LibFT4222-v1.4.8"
echo.
echo.******************************************************************************************
echo.* downloading '%WFVIEW_LIBFT4222_VERSION%.zip' into '%WFVIEW_LIBFT4222_SRC_DIR%'
echo.******************************************************************************************
if not exist "%WFVIEW_LIBFT4222_SRC_DIR%\%WFVIEW_LIBFT4222_VERSION%.zip" (
  if not exist "%WFVIEW_LIBFT4222_SRC_DIR%" mkdir "%WFVIEW_LIBFT4222_SRC_DIR%"
  call powershell -command "$webclient=new-object System.Net.WebClient; $webclient.DownloadFile('%WFVIEW_LIBFT4222_URI%','%WFVIEW_LIBFT4222_SRC_DIR%\%WFVIEW_LIBFT4222_VERSION%.zip'); $webclient.DownloadFile('%WFVIEW_LIBFT4222_URI%','%WFVIEW_LIBFT4222_SRC_DIR%\%WFVIEW_LIBFT4222_VERSION%.zip');" 2>nul
  rem $webclient.BaseAddress='https://ftdichip.com'; $webclient.Headers.Add('method','POST'); 
)
if not exist "%WFVIEW_LIBFT4222_SRC_DIR%\%WFVIEW_LIBFT4222_VERSION%.zip" (
  echo.error: download of '%WFVIEW_LIBFT4222_VERSION%.zip' failed 
) else (
  echo. '%WFVIEW_LIBFT4222_VERSION%.zip' ok
)
if exist "%WFVIEW_LIBFT4222_SRC_DIR%\%WFVIEW_LIBFT4222_VERSION%.zip" (
  echo.
  echo.******************************************************************************************
  echo.* extracting '%WFVIEW_LIBFT4222_VERSION%.zip' into '%WFVIEW_LIBFT4222_DIR%'
  echo.******************************************************************************************
  if not exist "%WFVIEW_LIBFT4222_DIR%" mkdir "%WFVIEW_LIBFT4222_DIR%"
  setlocal EnableDelayedExpansion
  set _has_data=false
  for /f %%i in ('dir /a /b "%WFVIEW_LIBFT4222_DIR%"') do set _has_data=true
  if "!_has_data!" neq "true" (
    call powershell -command "Expand-Archive -Force '%WFVIEW_LIBFT4222_SRC_DIR%\%WFVIEW_LIBFT4222_VERSION%.zip' '%WFVIEW_LIBFT4222_DIR%'"
    rem for /l %%i in (1,1,5) do call choice /C y /D y /N /T 1 1>nul &echo|set /p="."
    rem echo.
  )
  set _has_data=false
  for /f %%i in ('dir /a /b "%WFVIEW_LIBFT4222_DIR%"') do set _has_data=true
  if "!_has_data!" neq "true" (
    echo.error: extraction of '%WFVIEW_LIBFT4222_VERSION%.zip' failed
  ) else (
    echo. '%WFVIEW_LIBFT4222_DIR%' ok
  )
  endlocal
)
echo.

if "%MAKER_ENV_VERBOSE%" neq "" set WFVIEW_
cd /d "%WFVIEW_LIBS_SRC_DIR%"
