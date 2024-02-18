@rem https://github.com/hankst69/html5_rtsp_player
@rem https://github.com/Streamedian/html5_rtsp_player
@call "%~dp0scripts\clone_in_folder.bat" "%~dp0ProjectWebCam\html5_rtsp_player\" "https://github.com/hankst69/html5_rtsp_player" --changeDir
@git remote -v
@git status
