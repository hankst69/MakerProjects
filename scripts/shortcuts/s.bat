@if /i "%~1" equ "--shortcut-info" echo shortcuts&goto :EOF
@rem echo shortcuts %*
@"%~dp0\shortcuts.bat" %*