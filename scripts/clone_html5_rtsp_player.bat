@rem https://github.com/hankst69/html5_rtsp_player
@rem https://github.com/Streamedian/html5_rtsp_player
@echo off
call "%~dp0\maker_env.bat"

rem set "_HTML5_RTSP_PLAYER_DIR=%MAKER_ROOT%ProjectWebCam\html5_rtsp_player"
rem set "_HTML5_RTSP_PLAYER_DIR=%MAKER_PROJECTS%\WebCam\html5_rtsp_player"
set "_HTML5_RTSP_PLAYER_DIR=%MAKER_PROJECTS%\Web\html5_rtsp_player"

call "%MAKER_SCRIPTS%\clone_in_folder.bat" "%_HTML5_RTSP_PLAYER_DIR%" "https://github.com/hankst69/html5_rtsp_player" --changeDir
