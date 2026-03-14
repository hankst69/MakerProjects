@if /i "%~1" equ "--shortcut-info" echo git_repos&goto :EOF
@echo git_repos %*
@"%~dp0git_repos.bat" %*