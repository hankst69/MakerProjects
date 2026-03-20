@if /i "%~1" equ "--shortcut-info" echo clone&goto :EOF
@if "%*" neq "" @echo.%cd%^>clone %*
@"%~dp0\clone.bat" %*