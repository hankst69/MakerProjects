@echo off
:: %1 : origin_repo url
:: %2 : branch_name to sync
call "%~dp0\git_merge_remote_repo.bat" %*
