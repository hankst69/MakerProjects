@echo off
:: %1 : origin_repo url
:: %2 : branch_name to sync
set "_repo_url=%~1"
set "_branch=%~2"

if "%_repo_url%" equ "" (
  echo error: repo-url argument missing
  echo.
  :Usage
  echo.Usage: %~n0 repo-url [branch_name]
  goto :EOF
)
if "%_branch%" equ "" set set "_branch=main"

:: Step 1: Add the upstream repository as a remote
git remote add upstream "%_repo_url%" 2>nul
:: Step 2: Fetch changes from the upstream repository
git fetch upstream
:: Step 3: Merge changes into your local branch
git checkout %_branch%
rem git pull
git merge upstream/%_branch%
:: Step 4: Push the updated branch to your fork
git push origin %_branch%
