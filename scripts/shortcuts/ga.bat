@if /i "%~1" equ "--shortcut-info" echo git add&goto :EOF
@echo.%cd%^>git add %*
@git add %*
@git status