@if /i "%~1" equ "--shortcut-info" echo git_rm_permanent&goto :EOF
@"%~dp0..\core\git_rm_permanent.bat" %*