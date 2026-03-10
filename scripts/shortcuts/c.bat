@if /i "%~1" equ "--shortcut-info" echo clone&goto :EOF
@echo clone %*
@"%~dp0\..\..\clone.bat" %*