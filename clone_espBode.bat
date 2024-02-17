@rem https://github.com/hankst69/espBode.git
@rem https://github.com/Hamhackin/espBode
@rem https://github.com/timkoers/espBode
@rem https://github.com/sq6sfo/espBode
@call "%~dp0clone_in_folder.bat" "%~dp0espBode\" "https://github.com/hankst69/espBode.git"
@cd "%~dp0espBode"
@git switch awgDevices
@git status