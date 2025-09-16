@echo off
SETLOCAL ENABLEEXTENSIONS
SETLOCAL ENABLEDELAYEDEXPANSION
call :List_Git_Repos_in_Dir "%~dp0"
goto :EOF

:List_Git_Repos_in_Dir
for /D %%f in (%~1*) do if exist "%%~f\.git" (call :Dump_Git_Repo "%%f") else (call :List_Git_Repos_in_Dir "%%f\")
goto :EOF

:Dump_Git_Repo
pushd "%~1"
>"%TEMP%\strlen.tmp" echo."%~1"
set _STRING_LENGTH=0
for %%? in (%TEMP%\strlen.tmp) do (set /A _STRING_LENGTH=%%~z? - 4)
set "_RIGHT_PADDING= "
for /L %%i in (!_STRING_LENGTH!,1,60) do set "_RIGHT_PADDING=!_RIGHT_PADDING! "
for /f "tokens=2,3" %%i in ('call git remote -v') do @if /I "%%j" equ "(push)" echo. "%~1"!_RIGHT_PADDING!   	^(%%i^)
popd
goto :EOF