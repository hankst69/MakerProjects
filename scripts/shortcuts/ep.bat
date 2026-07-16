@if /i "%~1" equ "--shortcut-info" echo echo_path&goto :EOF
@echo echo_path %*
@echo:%PATH:;= & echo:%