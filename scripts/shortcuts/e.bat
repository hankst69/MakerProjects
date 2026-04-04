@if /i "%~1" equ "--shortcut-info" echo ensure&goto :EOF
@rem if "%*" neq "" @echo.%cd%^>ensure %*
@"%~dp0\ensure.bat" %*