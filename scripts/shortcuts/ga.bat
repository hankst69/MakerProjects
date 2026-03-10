@if /i "%~1" equ "--shortcut-info" echo git add&goto :EOF
@echo git add %*
@git add %*