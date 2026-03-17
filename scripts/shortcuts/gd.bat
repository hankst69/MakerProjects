@if /i "%~1" equ "--shortcut-info" echo git diff&goto :EOF
@echo.%cd%^>git diff %*
@git diff %*
