@if /i "%~1" equ "--shortcut-info" echo build&goto :EOF
@echo build %*
@"%~dp0\build.bat" %*