@if /i "%~1" equ "--shortcut-info" echo git_merge_remote_repo&goto :EOF
@"%~dp0..\core\git_merge_remote_repo.bat" %*