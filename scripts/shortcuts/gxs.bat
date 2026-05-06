@if /i "%~1" equ "--shortcut-info" echo git_extract_subdir&goto :EOF
@"%~dp0..\core\git_extract_subdir.bat" %*