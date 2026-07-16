@if /i "%~1" equ "--shortcut-info" echo echo_include&goto :EOF
@echo echo_include %*
@echo:%INCLUDE:;= & echo:%