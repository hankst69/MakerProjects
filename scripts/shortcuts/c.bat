@if /i "%~1" equ "--shortcut-info" echo clone&goto :EOF
@::@echo.%cd%^>clone %*
@"%~dp0\clone.bat" %*