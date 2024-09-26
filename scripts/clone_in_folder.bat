@echo off
rem set "_MAKER_ROOT=%~dp0..\"
rem echo on
if "%~1" equ "" echo error: missing argument 'target-folder' &goto :Usage
if "%~2" equ "" echo error: missing argument 'git-repo-url' &goto :Usage
rem if not exist "%~1" mkdir "%~1"
rem arg1: target-folder '%1' '%~1' '%~dp1'
rem arg2: git-repo-url  '%2' '%~2' '%~dp2'
goto :Start
:Usage
echo.
echo USAGE: %~n0 target-folder git-repo-url
echo.
goto :EOF

:Start
doskey home="%~dp0home.cmd"
set _GIT_REPO_EXISTS=
if exist "%~1.git\config" (
  grep "%~2" "%~1.git\config" 1>NUL 2>NUL
  if %ERRORLEVEL% equ 0 (
    set _GIT_REPO_EXISTS=true
  )
)
if "%_GIT_REPO_EXISTS%" equ "true" (
  set _GIT_REPO_EXISTS=
  echo ********************************************************************************
  echo * '%~2' is already cloned into '%~1'
  echo *
  if exist "%~1\clone.bat"     echo * to clone fresh delete the content in folder '%~1' ^(except file clone.bat^)
  if not exist "%~1\clone.bat" echo * to clone fresh delete the content in folder '%~1'
  if not exist "%~1\clone.bat" echo * with 'rmdir /s /q "%~1"'
  echo *
  echo * the status in '%~1' is:
  echo ********************************************************************************
  pushd "%~1"
  git remote -v
  if /I "%~4" equ "--switchBranch" (echo. & git switch %~5)
  git status
  git fetch
  popd
  if /I "%~3" equ "--changeDir" (cd "%~1")
  echo.
  goto :EOF
)
if %ERRORLEVEL% equ 1 (
  echo ********************************************************************************
  echo * a different repository than '%~2' is already cloned into '%~1'
  echo *
  if exist "%~1\clone.bat"     echo * to clone fresh delete the content in folder '%~1' ^(except file clone.bat^)
  if not exist "%~1\clone.bat" echo * to clone fresh delete the content in folder '%~1'
  if not exist "%~1\clone.bat" echo * with 'rmdir /s /q "%~1"'
  echo *
  echo * currently cloned: 
  echo ********************************************************************************
  grep ".git" .git\config
  echo.
  goto :EOF
)

:Clone
echo ********************************************************************************
echo * cloning "%~2" into "%~1"
echo ********************************************************************************
if not exist "%~1" mkdir "%~1"
if exist "%~1\clone.bat" (
  if exist "%~dp0clone.tmp" (del /F /Q "%~dp0clone.tmp")
  copy "%~1\clone.bat" "%~dp0clone.tmp"
  del /F /Q "%~1\clone.bat"
)
pushd "%~1"
cd
git clone "%~2" .
set _CLONE_ERROR=%ERRORLEVEL%
if exist "%~dp0clone.tmp" (
  copy "%~dp0clone.tmp" "%~1\clone.bat"
  del /F /Q "%~dp0clone.tmp"
)
if %_CLONE_ERROR% neq 0 (echo. & echo error: git clone failed & popd & goto:EOF)
echo.
echo ********************************************************************************
echo * the status in '%~1' is:
echo ********************************************************************************
git remote -v
if /I "%~3" equ "--switchBranch" (echo. & git switch %~4)
if /I "%~4" equ "--switchBranch" (echo. & git switch %~5)
git status
popd
if /I "%~3" equ "--changeDir" (cd "%~1")
if /I "%~5" equ "--changeDir" (cd "%~1")