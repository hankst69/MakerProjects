@if /i "%~1" equ "--shortcut-info" echo git pull ^& git push&goto :EOF
@echo.%cd%^>git pull %*
@git pull %*
@echo.%cd%^>git push %*
@git push %*
