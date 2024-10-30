@echo off
rem arg1: target-folder '%1' '%~1' '%~dp1'
rem arg2: git-repo-url  '%2' '%~2' '%~dp2'
set "_SCRIPT_ROOT=%~dp0"
set "_SCRIPT_NAME=%~n0"
set "_CURRENT_DIR=%cd%"
set _TARGET_DIR=
set _CLONE_URL=
set _CLONE_REPO=
set _SILENT_CLONE_MODE=
set _SWITCH_BRANCH=
set _CHANGE_DIR=
set _FREE_ARGS=
:param_loop
if /I "%~1" equ "--silent"       (set "_SILENT_CLONE_MODE=true" &shift &goto :param_loop)
if /I "%~1" equ "--changeDir"    (set "_CHANGE_DIR=true" &shift &goto :param_loop)
if /I "%~1" equ "--switchBranch" (set "_SWITCH_BRANCH=%~2" &shift &shift &goto :param_loop)
if "%~1" neq "" if "%_TARGET_DIR%" equ "" (set "_TARGET_DIR=%~1" &shift &goto :param_loop)
if "%~1" neq "" if "%_CLONE_URL%"  equ "" (set "_CLONE_URL=%~1" &set "_CLONE_REPO=%~nx1" &shift /1 &goto :param_loop)
if "%~1" neq "" (set "_FREE_ARGS=%_FREE_ARGS% %1"&shift &goto :param_loop)
if "%_TARGET_DIR%" equ "" echo error: missing argument 'target-folder' &goto :Usage
if "%_CLONE_URL%" equ "" echo error: missing argument 'git-repo-url' &goto :Usage
goto :Start &rem disable this statement for debugging
echo _TARGET_DIR        = "%_TARGET_DIR%"
echo _TARGET_DIR        = "%_CLONE_URL%"
echo _CLONE_REPO        = "%_CLONE_REPO%"
echo _SILENT_CLONE_MODE = "%_SILENT_CLONE_MODE%"
echo _SWITCH_BRANCH     = "%_SWITCH_BRANCH%"
echo _CHANGE_DIR        = "%_CHANGE_DIR%"
echo _FREE_ARGS         = %_FREE_ARGS%
rem goto :Exit
goto :Start

:Usage
echo.
echo USAGE: %_SCRIPT_NAME% target-folder git-repo-url [--changeDir] [--switchBranch branch] [--silent]
echo.
goto :Exit

:Exit
if "%_CHANGE_DIR%" equ "" (cd "%_CURRENT_DIR%")
set _SCRIPT_ROOT=
set _SCRIPT_NAME=
set _CURRENT_DIR=
set _TARGET_DIR=
set _CLONE_URL=
set _CLONE_REPO=
set _SILENT_CLONE_MODE=
set _SWITCH_BRANCH=
set _CHANGE_DIR=
set _FREE_ARGS=
goto :EOF

:Start
doskey home="%_SCRIPT_ROOT%home.cmd"
if not exist "%_TARGET_DIR%\.git\config" goto :Clone
grep ".git" "%_TARGET_DIR%\.git\config"1>"%TEMP%\%_SCRIPT_NAME%_git.tmp" 2>nul
grep "%_CLONE_URL%" "%_TARGET_DIR%\.git\config"1>"%TEMP%\%_SCRIPT_NAME%_match.tmp" 2>nul
rem type "%TEMP%\%_SCRIPT_NAME%_git.tmp"
set /p _GIT_REPO=<"%TEMP%\%_SCRIPT_NAME%_git.tmp"
set /p _GIT_REPO_MATCHES=<"%TEMP%\%_SCRIPT_NAME%_match.tmp"
if "%_GIT_REPO_MATCHES%" NEQ "" (
  if "%_SILENT_CLONE_MODE%" neq "true" (
  echo ********************************************************************************
  echo * '%_CLONE_REPO%' is already cloned into folder:
  echo *  '%_TARGET_DIR%'
  echo * to clone '%_CLONE_REPO%' freshly, all content needs to be removed first:
  echo *  'rmdir /s /q "%_TARGET_DIR%"'
  echo ********************************************************************************
  )
  pushd "%_TARGET_DIR%"
  git remote -v
  if "%_SWITCH_BRANCH%" neq "" (echo. & git switch %_SWITCH_BRANCH%)
  git status
  git fetch
  popd
  if "%_CHANGE_DIR%" neq "" (cd "%_TARGET_DIR%")
) else (
  echo ********************************************************************************
  echo * a different repository than '%_CLONE_REPO%' is already cloned into folder:
  echo *  '%_TARGET_DIR%'
  echo * currently cloned: 
  echo *%_GIT_REPO%
  echo * to clone '%_CLONE_REPO%' freshly, all content needs to be removed first:
  echo *  'rmdir /s /q "%_TARGET_DIR%"'
  echo ********************************************************************************
)
echo.
set _GIT_REPO=
set _GIT_REPO_MATCHES=
goto :Exit


:Clone
rem if "%_SILENT_CLONE_MODE%" neq "true" (
echo ********************************************************************************
echo * cloning "%_CLONE_URL%" into "%_TARGET_DIR%"
echo ********************************************************************************
rem )
if not exist "%_TARGET_DIR%" mkdir "%_TARGET_DIR%"
rem if exist "%_TARGET_DIR%\clone.bat" (
rem   if exist "%_SCRIPT_ROOT%clone.tmp" (del /F /Q "%_SCRIPT_ROOT%clone.tmp")
rem   copy "%_TARGET_DIR%\clone.bat" "%_SCRIPT_ROOT%clone.tmp"
rem   del /F /Q "%_TARGET_DIR%\clone.bat"
rem )
pushd "%_TARGET_DIR%"
cd
echo on
git clone --config core.autocrlf=false %_FREE_ARGS% "%_CLONE_URL%" . 
@echo off
set _CLONE_ERROR=%ERRORLEVEL%
rem if exist "%_SCRIPT_ROOT%clone.tmp" (
rem   copy "%_SCRIPT_ROOT%clone.tmp" "%_TARGET_DIR%\clone.bat"
rem   del /F /Q "%_SCRIPT_ROOT%clone.tmp"
rem )
if %_CLONE_ERROR% neq 0 (echo. & echo error: git clone failed & popd & goto:EOF)
if "%_SWITCH_BRANCH%" neq "" (echo. & git switch %_SWITCH_BRANCH%)
if "%_SILENT_CLONE_MODE%" neq "true" (
  echo.
  echo ********************************************************************************
  echo * the status in '%_TARGET_DIR%' is:
  echo ********************************************************************************
  git remote -v
  git status
)
if "%_CHANGE_DIR%" neq "" (cd "%_TARGET_DIR%")
goto :Exit
