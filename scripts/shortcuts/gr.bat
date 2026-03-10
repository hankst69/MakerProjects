@if /i "%~1" equ "--shortcut-info" echo git_repos&goto :EOF
@echo git_repos %*
@"%~dp0\..\..\git_repos.bat" %*