@echo off
rem %1: target-folder
rem %2: git-repo-url
if "%~1" equ "" echo error: missing argument 'target-folder' &goto :Usage
if "%~2" equ "" echo error: missing argument 'git-repo-url' &goto :Usage
goto :Start
:Usage
echo.
echo USAGE: %~n0 target-folder git-repo-url
echo.
goto :EOF

:Start
doskey home="%~dp0home.cmd"
grep "%~2" "%~dp1.git\config" 1>NUL 2>NUL
rem echo %ERRORLEVEL%
if %ERRORLEVEL% equ 0 (
  echo ********************************************************************************
  echo * '%~2' is already cloned into '%~dp1'
  echo *
  if exist "%~dp1clone.bat"     echo * to clone fresh delete the content in folder '%~dp1' ^(except file clone.bat^)
  if not exist "%~dp1clone.bat" echo * to clone fresh delete the content in folder '%~dp1'
  if not exist "%~dp1clone.bat" echo * with 'rmdir /s /q "%~dp1"'
  echo *
  echo * the status in '%~dp1' is:
  echo ********************************************************************************
  pushd "%~dp1"
  git remote -v
  if /I "%~4" equ "--switchBranch" (echo. & git switch %~5)
  git status
  git fetch
  popd
  if /I "%~3" equ "--changeDir" (cd "%~dp1")
  echo.
  goto :EOF
)
if %ERRORLEVEL% equ 1 (
  echo ********************************************************************************
  echo * a different repository than '%~2' is already cloned into '%~dp1'
  echo *
  if exist "%~dp1clone.bat"     echo * to clone fresh delete the content in folder '%~dp1' ^(except file clone.bat^)
  if not exist "%~dp1clone.bat" echo * to clone fresh delete the content in folder '%~dp1'
  if not exist "%~dp1clone.bat" echo * with 'rmdir /s /q "%~dp1"'
  echo *
  echo * currently cloned: 
  echo ********************************************************************************
  grep ".git" .git\config
  echo.
  goto :EOF
)

:Clone
echo ********************************************************************************
echo * cloning "%~2" into "%~dp1"
echo ********************************************************************************
if not exist "%~dp1" mkdir "%~dp1"
if exist "%~dp1clone.bat" (
  if exist "%~dp0clone.tmp" (del /F /Q "%~dp0clone.tmp")
  copy "%~dp1clone.bat" "%~dp0clone.tmp"
  del /F /Q "%~dp1clone.bat"
)
pushd "%~dp1"
cd
git clone "%~2" .
set _CLONE_ERROR=%ERRORLEVEL%
if exist "%~dp0clone.tmp" (
  copy "%~dp0clone.tmp" "%~dp1clone.bat"
  del /F /Q "%~dp0clone.tmp"
)
if %_CLONE_ERROR% neq 0 (echo. & echo error: git clone failed & popd & goto:EOF)
echo.
echo ********************************************************************************
echo * the status in '%~dp1' is:
echo ********************************************************************************
git remote -v
if /I "%~4" equ "--switchBranch" (echo. & git switch %~5)
git status
popd
if /I "%~3" equ "--changeDir" (cd "%~dp1")
