@if /i "%~1" equ "--shortcut-info" echo git_sync_fork&goto :EOF
@"%~dp0..\core\git_sync_fork.bat" %*