@if /i "%~1" equ "--shortcut-info" echo git pull&goto :EOF
@echo git pull %*
@git pull %*