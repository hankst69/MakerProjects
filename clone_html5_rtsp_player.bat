@rem https://github.com/hankst69/html5_rtsp_player
@rem https://github.com/Streamedian/html5_rtsp_player
@echo off
set "_MAKER_ROOT=%~dp0"
rem set "_HTML5_RTSP_PLAYER_DIR=%_MAKER_ROOT%ProjectWebCam\html5_rtsp_player"
rem set "_HTML5_RTSP_PLAYER_DIR=%_MAKER_ROOT%projects\WebCam\html5_rtsp_player"
set "_HTML5_RTSP_PLAYER_DIR=%_MAKER_ROOT%projects\web\html5_rtsp_player"

call "%_MAKER_ROOT%scripts\clone_in_folder.bat" "%_HTML5_RTSP_PLAYER_DIR%" "https://github.com/hankst69/html5_rtsp_player" --changeDir
