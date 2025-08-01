@echo off
rem arg1: target-folder '%1' '%~1' '%~dp1'
rem arg2: git-repo-url  '%2' '%~2' '%~dp2'
set "_SCRIPT_ROOT=%~dp0"
set "_SCRIPT_NAME=%~n0"
set "_CURRENT_DIR=%cd%"
set _TARGET_DIR=
set _GIT_CLONE_URL=
set _GIT_CLONE_REPO=
set _SILENT_CLONE_MODE=
set _SWITCH_BRANCH=
set _CHECKOUT_TAG=
set _CHANGE_DIR=
set _FREE_ARGS=
:param_loop
if /I "%~1" equ "--silent"       (set "_SILENT_CLONE_MODE=true" &shift &goto :param_loop)
if /I "%~1" equ "--changeDir"    (set "_CHANGE_DIR=true" &shift &goto :param_loop)
if /I "%~1" equ "--switchBranch" (set "_SWITCH_BRANCH=%~2" &shift &shift &goto :param_loop)
if /I "%~1" equ "--checkoutTag"  (set "_CHECKOUT_TAG=%~2" &shift &shift &goto :param_loop)
if "%~1" neq "" if "%_TARGET_DIR%" equ "" (set "_TARGET_DIR=%~1" &shift &goto :param_loop)
if "%~1" neq "" if "%_GIT_CLONE_URL%"  equ "" (set "_GIT_CLONE_URL=%~1" &set "_GIT_CLONE_REPO=%~nx1" &shift /1 &goto :param_loop)
if "%~1" neq "" (set "_FREE_ARGS=%_FREE_ARGS% %1"&shift &goto :param_loop)
if "%_TARGET_DIR%" equ "" echo error: missing argument 'target-folder' &goto :Usage
if "%_GIT_CLONE_URL%" equ "" echo error: missing argument 'git-repo-url' &goto :Usage
if "%MAKER_ENV_VERBOSE%" equ "" goto :Start
echo _TARGET_DIR        = "%_TARGET_DIR%"
echo _GIT_CLONE_URL     = "%_GIT_CLONE_URL%"
echo _GIT_CLONE_REPO    = "%_GIT_CLONE_REPO%"
echo _SILENT_CLONE_MODE = "%_SILENT_CLONE_MODE%"
echo _SWITCH_BRANCH     = "%_SWITCH_BRANCH%"
echo _CHECKOUT_TAG      = "%_CHECKOUT_TAG%"
echo _CHANGE_DIR        = "%_CHANGE_DIR%"
echo _FREE_ARGS         = %_FREE_ARGS%
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
set _GIT_CLONE_URL=
set _GIT_CLONE_REPO=
set _SILENT_CLONE_MODE=
set _SWITCH_BRANCH=
set _CHECKOUT_TAG=
set _CHANGE_DIR=
set _FREE_ARGS=
goto :EOF

:Start
doskey home="%_SCRIPT_ROOT%home.cmd"
if not exist "%_TARGET_DIR%\.git\config" goto :Clone
set _GIT_CURRENT_URL=
set _GIT_CURRENT_REPO=
pushd "%_TARGET_DIR%"
rem for /f "tokens=3" %%u in ('grep ".git" "%_TARGET_DIR%\.git\config"') do @if "%%~u" neq "" (set "_GIT_CURRENT_URL=%%~u" & set "_GIT_CURRENT_REPO=%%~nxu")
for /f "tokens=2" %%u in ('call git remote -v') do @if "%%~u" neq "" (set "_GIT_CURRENT_URL=%%~u" & set "_GIT_CURRENT_REPO=%%~nxu")
rem echo "%_GIT_CURRENT_REPO%" "%_GIT_CURRENT_URL%"
popd
if /I "%_GIT_CURRENT_URL%" equ "%_GIT_CLONE_URL%" (
  if "%_SILENT_CLONE_MODE%" neq "true" (
    echo ******************************************************************************************
    echo * '%_GIT_CLONE_REPO%' is already cloned in '%_TARGET_DIR%'
    rem echo * to clone '%_GIT_CLONE_REPO%' freshly, remove all content via: 'rmdir /s /q "%_TARGET_DIR%"'
	  echo * ^(you can delete all current content with 'rmdir /s /q "%_TARGET_DIR%"'^)
    echo ******************************************************************************************
  )
  pushd "%_TARGET_DIR%"
  if "%_SILENT_CLONE_MODE%" neq "true" (
    git remote -v
    if "%_SWITCH_BRANCH%" neq "" (
      echo.
      git switch %_SWITCH_BRANCH%
    )
    git status
    git fetch
  ) else (
    if "%_SWITCH_BRANCH%" neq "" (
      echo.
      git switch %_SWITCH_BRANCH% 1>nul 2>nul
    )
  )
  popd
  if "%_CHANGE_DIR%" neq "" (cd "%_TARGET_DIR%")
) else (
  echo ******************************************************************************************
  echo * WARNING:
  echo *  you try to clone '%_GIT_CLONE_REPO%' into folder '%_TARGET_DIR%'
  echo *  but '%_GIT_CURRENT_REPO%' is currently cloned in there!
  echo * 
  echo *  to clone '%_GIT_CLONE_REPO%' into the folder '%_TARGET_DIR%'
  echo *  you first have to delete all current content!
  echo *  ^(you can do so with 'rmdir /s /q "%_TARGET_DIR%"'^)
  echo ******************************************************************************************
)
if "%_SILENT_CLONE_MODE%" neq "true" echo.
set _GIT_REPO=
goto :Exit


:Clone
rem if "%_SILENT_CLONE_MODE%" neq "true" (
echo ******************************************************************************************
echo * cloning "%_GIT_CLONE_URL%" into "%_TARGET_DIR%"
echo ******************************************************************************************
rem )
if not exist "%_TARGET_DIR%" mkdir "%_TARGET_DIR%"
pushd "%_TARGET_DIR%"
if "%_CHECKOUT_TAG%" equ "" (
  echo git clone --config core.autocrlf=false %_FREE_ARGS% "%_GIT_CLONE_URL%" "%_TARGET_DIR%"
  git clone --config core.autocrlf=false %_FREE_ARGS% "%_GIT_CLONE_URL%" .
) else (
  rem https://stackoverflow.com/questions/20280726/how-to-clone-a-specific-git-tag
  echo git clone --config core.autocrlf=false %_FREE_ARGS%  --depth 1 --branch "%_CHECKOUT_TAG%" "%_GIT_CLONE_URL%" "%_TARGET_DIR%"
  git clone --config core.autocrlf=false %_FREE_ARGS% --depth 1 --branch "%_CHECKOUT_TAG%" "%_GIT_CLONE_URL%" .
)
if %ERRORLEVEL% neq 0 (echo. & echo error: git clone failed & goto:EOF)
if "%_SWITCH_BRANCH%" neq "" (echo. & git switch %_SWITCH_BRANCH%)
if "%_SILENT_CLONE_MODE%" neq "true" (
  echo.
  echo ******************************************************************************************
  echo * the status in '%_TARGET_DIR%' is:
  echo ******************************************************************************************
  git remote -v
  git status
)
popd
if "%_CHANGE_DIR%" neq "" (cd "%_TARGET_DIR%")
goto :Exit
