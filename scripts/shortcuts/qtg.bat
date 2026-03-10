@if /i "%~1" equ "--shortcut-info" echo QtGammaray&goto :EOF
@echo QtGammaray %*
@"%~dp0\qtgammaray.bat" %*