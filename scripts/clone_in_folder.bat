@echo off
rem arg1: target-folder '%1' '%~1' '%~dp1'
rem arg2: git-repo-url  '%2' '%~2' '%~dp2'
if "%~1" equ "" echo error: missing argument 'target-folder' &goto :Usage
if "%~2" equ "" echo error: missing argument 'git-repo-url' &goto :Usage
set _SILENT_CLONE_MODE=
if /I "%~3" equ "--silent" (shift /3&set _SILENT_CLONE_MODE=true)
if /I "%~4" equ "--silent" (shift /4&set _SILENT_CLONE_MODE=true)
if /I "%~5" equ "--silent" (shift /5&set _SILENT_CLONE_MODE=true)
if /I "%~6" equ "--silent" (shift /6&set _SILENT_CLONE_MODE=true)
goto :Start

:Usage
echo.
echo USAGE: %~n0 target-folder git-repo-url [--changeDir] [--switchBranch branch] [--silent]
echo.
goto :EOF

:Start
doskey home="%~dp0home.cmd"
if not exist "%~1\.git\config" goto :Clone
grep ".git" "%~1\.git\config"1>"%TEMP%\%~n0_git.tmp" 2>nul
grep "%~2" "%~1\.git\config"1>"%TEMP%\%~n0_match.tmp" 2>nul
rem type "%TEMP%\%~n0_git.tmp"
set /p _GIT_REPO=<"%TEMP%\%~n0_git.tmp"
set /p _GIT_REPO_MATCHES=<"%TEMP%\%~n0_match.tmp"
if "%_GIT_REPO_MATCHES%" NEQ "" (
  if "%_SILENT_CLONE_MODE%" neq "true" (
  echo ********************************************************************************
  echo * '%~nx2' is already cloned into folder:
  echo *  '%~1'
  echo * to clone '%~nx2' freshly, all content needs to be removed first:
  echo *  'rmdir /s /q "%~1"'
  echo ********************************************************************************
  )
  pushd "%~1"
  git remote -v
  if /I "%~4" equ "--switchBranch" (echo. & git switch %~5)
  git status
  git fetch
  popd
  if /I "%~3" equ "--changeDir" (cd "%~1")
) else (
  echo ********************************************************************************
  echo * a different repository than '%~nx2' is already cloned into folder:
  echo *  '%~1'
  echo * currently cloned: 
  echo *%_GIT_REPO%
  echo * to clone '%~nx2' freshly, all content needs to be removed first:
  echo *  'rmdir /s /q "%~1"'
  echo ********************************************************************************
)
echo.
set _GIT_REPO=
set _GIT_REPO_MATCHES=
goto :EOF


:Clone
rem if "%_SILENT_CLONE_MODE%" neq "true" (
echo ********************************************************************************
echo * cloning "%~2" into "%~1"
echo ********************************************************************************
rem )
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
if /I "%~3" equ "--switchBranch" (echo. & git switch %~4)
if /I "%~4" equ "--switchBranch" (echo. & git switch %~5)
if "%_SILENT_CLONE_MODE%" neq "true" (
  echo.
  echo ********************************************************************************
  echo * the status in '%~1' is:
  echo ********************************************************************************
  git remote -v
  git status
)
popd
if /I "%~3" equ "--changeDir" (cd "%~1")
if /I "%~5" equ "--changeDir" (cd "%~1")