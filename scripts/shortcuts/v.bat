@if /i "%~1" equ "--shortcut-info" echo validate&goto :EOF
@if "%*" neq "" @echo.%cd%^>validate %*
@"%~dp0\validate.bat" %*