@if /i "%~1" equ "--shortcut-info" echo ensure&goto :EOF
@if "%*" neq "" @echo.%cd%^>ensure %*
@"%~dp0\ensure.bat" %*