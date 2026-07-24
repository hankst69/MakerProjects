@echo off
call "%~dp0\maker_env.bat" %*

set "RT950PRO_CHIRP_DIR=%MAKER_DIR_PROJECTS%\rt950pro_chirp"
set "RT950PRO_CHIRP_DEV_BRANCH=dev"

rem RT950PRO_CHIRP repository
:: https://github.com/hankst69/Chirp_Radtel-RT-950-Pro.git
rem source
:: https://github.com/NathanBarguss/Chirp_Radtel-RT-950-Pro.git
rem forks:
:: https://github.com/Dadud/Chirp_Radtel-RT-950-Pro.git
:: https://github.com/michael-muir/Chirp_Radtel-RT-950-Pro.git
:: https://github.com/RevEngOps/Chirp_Radtel-RT-950-Pro.git
call "%MAKER_ENV_CORE%\clone_in_folder" "%RT950PRO_CHIRP_DIR%" "https://github.com/hankst69/Chirp_Radtel-RT-950-Pro.git" %MAKER_MSG_SILENT%

cd /d "%RT950PRO_CHIRP_DIR%"
:: Sync this Forks dev branch with other forkks main branch
echo.
call "%MAKER_ENV_CORE%\git_checkout_remote_repo" "https://github.com/michael-muir/Chirp_Radtel-RT-950-Pro.git" tone_mode_fixes  dev_michael-muir  upstream_michael-muir
echo.
call "%MAKER_ENV_CORE%\git_checkout_remote_repo" "https://github.com/RevEngOps/Chirp_Radtel-RT-950-Pro.git"    fixes            dev_RevEngOps     upstream_RevEngOps
echo.
call "%MAKER_ENV_CORE%\git_checkout_remote_repo" "https://github.com/Dadud/Chirp_Radtel-RT-950-Pro.git"        main             dev_Dadud         upstream_Dadud 

:: Sync this Forks main branch with Fork-Origin main branch
echo.
call "%MAKER_ENV_CORE%\git_merge_remote_repo" "https://github.com/NathanBarguss/Chirp_Radtel-RT-950-Pro.git" main

echo.
call git switch -c %RT950PRO_CHIRP_DEV_BRANCH% 2>nul
call git switch %RT950PRO_CHIRP_DEV_BRANCH%
call git pull
