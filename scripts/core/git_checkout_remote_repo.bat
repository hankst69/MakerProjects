@echo off
:: %1 : other_repo url
:: %2 : other_repo_branch
:: %3 : this_repo_branch
:: %4 : other_repo_remote_name
set "_remote_url=%~1"
set "_remote_branch=%~2"
set "_local_branch=%~3"
set "_remote_name=%~4"

if "%_remote_url%" equ "" (
  echo error: repo-url argument missing
  echo.
  :Usage
  echo.Usage: %~n0 repo-url [repo-branch] [target-branch]
  goto :EOF
)
if "%_remote_branch%" equ "" set "_remote_branch=main"
if "%_local_branch%"  equ "" set "_local_branch=%_remote_branch%"
if "%_remote_name%"   equ "" set "_remote_name=upstream"

echo --------------------------------------------------------------------------------------
echo updating local branch "%_local_branch%" from remote "%_remote_url%/%_remote_branch%"
echo --------------------------------------------------------------------------------------
:: Step 1: Add the remote repository
git remote add %_remote_name% "%_remote_url%" 2>nul
:: Step 2: Fetch changes from the remote repository
git fetch %_remote_name%
:: Step 3: switch to (new) local branch
git switch -c %_local_branch% 2>nul
git switch %_local_branch% 2>nul
git branch --unset-upstream 2>nul
git switch -c main  2>nul
git switch main 2>nul
git branch -D %_local_branch%
rem git checkout -b %_local_branch% %_remote_name%/%_remote_branch% --no-track
git switch -c %_local_branch% %_remote_name%/%_remote_branch%
