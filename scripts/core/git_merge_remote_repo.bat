@echo off
:: %1 : other_repo url
:: %2 : other_repo_branch
:: %3 : this_repo_branch
:: %4 : other_repo_remote_name
:: %5 : push
set "_remote_url=%~1"
set "_remote_branch=%~2"
set "_local_branch=%~3"
set "_remote_name=%~4"
set "_do_not_push=%~5"

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
echo merging "%_remote_url%/%_remote_branch%" into local branch "%_local_branch%"
echo --------------------------------------------------------------------------------------

:: Step 1: Add the remote repository
git remote add %_remote_name% "%_remote_url%" 2>nul

:: Step 2: Fetch changes from the remote repository
git fetch %_remote_name%

:: Step 3: Switch to (new) local branch
git switch -c %_local_branch%
git checkout %_local_branch%
rem git pull

if "%_do_not_push%" equ "" (
  :: Step 4: Merge changes into your local branch
  git merge --commit %_remote_name%/%_remote_branch%
  :: Step 5: Push the updated branch to your fork
  git push origin %_local_branch%
) else (
  :: Step 4: Merge changes into your local branch
  git merge %_remote_name%/%_remote_branch%
)
