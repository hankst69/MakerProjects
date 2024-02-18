@echo off
rem %1: target-folder
rem %2: git-repo-url
if "%~1" equ "" echo missing argument 'target-folder' &goto :Usage
if "%~2" equ "" echo missing argument 'git-repo-url' &goto :Usage
goto :Start
:Usage
echo.
echo USAGE: %~n0 target-folder git-repo-url
echo.
goto :EOF

:Start
grep "%~2" "%~dp1.git\config" 1>NUL 2>NUL
rem echo %ERRORLEVEL%
if %ERRORLEVEL% equ 0 (
  echo '%~2' is already cloned into '%~dp1'
  echo.
  if exist "%~dp1clone.bat"     echo delete the content in folder '%~dp1' ^(except file clone.bat^) to clone fresh
  if not exist "%~dp1clone.bat" echo delete the content in folder '%~dp1' and try again to clone fresh
  if not exist "%~dp1clone.bat" echo use 'rmdir /s /q "%~dp1"' to rmove the folder
  echo.
  goto :EOF
)
if %ERRORLEVEL% equ 1 (
  echo a different repository than '%~2' is already cloned into '%~dp1'
  echo.
  echo currently cloned: 
  grep ".git" .git\config
  echo.
  if exist "%~dp1clone.bat"     echo delete the content in folder '%~dp1' ^(except file clone.bat^) to clone fresh
  if not exist "%~dp1clone.bat" echo delete the content in folder '%~dp1' and try again to clone fresh
  if not exist "%~dp1clone.bat" echo use 'rmdir /s /q "%~dp1"' to remove the folder
  echo.
  goto :EOF
)

:Clone
if not exist "%~dp1" mkdir "%~dp1"
echo cloning "%~2" into "%~dp1"
if exist "%~dp1clone.bat" (
  if exist "%~dp0clone.tmp" (del /F /Q "%~dp0clone.tmp")
  copy "%~dp1clone.bat" "%~dp0clone.tmp"
  del /F /Q "%~dp1clone.bat"
)

rem cd
rem git clone "%~2" "%~dp1"
pushd "%~dp1"
cd
git clone "%~2" .
popd

if exist "%~dp0clone.tmp" (
  copy "%~dp0clone.tmp" "%~dp1clone.bat"
  del /F /Q "%~dp0clone.tmp"
)

echo.
@git remote -v
@git status
if /I "%~3" equ "--changeDir" (cd "%~dp1")
if /I "%~4" equ "--switchBranch" (echo.& git switch %~5 & git status)
