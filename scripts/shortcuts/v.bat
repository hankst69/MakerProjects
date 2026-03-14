@if /i "%~1" equ "--shortcut-info" echo validate&goto :EOF
@::@echo.%cd%^>validate %*
@"%~dp0\validate.bat" %*