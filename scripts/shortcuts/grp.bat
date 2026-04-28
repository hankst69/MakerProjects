@if /i "%~1" equ "--shortcut-info" echo git_repos&goto :EOF
@"%~dp0..\core\git_repos.bat" %*