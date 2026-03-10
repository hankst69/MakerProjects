@if /i "%~1" equ "--shortcut-info" echo git status&goto :EOF
@echo git status %*
@@git status %*