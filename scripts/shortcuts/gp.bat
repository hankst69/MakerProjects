@if /i "%~1" equ "--shortcut-info" echo git pull&goto :EOF
@echo.%cd%^>git pull %*
@git pull %*