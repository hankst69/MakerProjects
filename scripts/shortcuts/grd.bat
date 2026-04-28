@if /i "%~1" equ "--shortcut-info" echo git_rmdir_permanent&goto :EOF
@"%~dp0..\core\git_rmdir_permanent.bat" %*