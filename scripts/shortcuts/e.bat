@if /i "%~1" equ "--shortcut-info" echo ensure&goto :EOF
@echo ensure %*
@"%~dp0\ensure.bat" %*