@echo off
rem fix: ******  B A T C H   R E C U R S I O N  exceeds STACK limits ******
rem https://stackoverflow.com/questions/11916823/batch-limitation-maximum-recursion-while-browsing-menus
rem SETLOCAL ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION
call :List_Git_Repos_in_Dir "%~dp0"
goto :EOF

:List_Git_Repos_in_Dir
rem fix: ******  B A T C H   R E C U R S I O N  exceeds STACK limits ******
rem VERIFY OTHER 2>nul &SETLOCAL ENABLEEXTENSIONS &IF ERRORLEVEL 1 (echo CMD extensions not available & goto :EOF)
SETLOCAL ENABLEEXTENSIONS
for /D %%f in (%~1*) do if exist "%%~f\.git" (call :Dump_Git_Repo "%%f") else (call :List_Git_Repos_in_Dir "%%f\")
ENDLOCAL
goto :EOF

:Dump_Git_Repo
rem fix: ******  B A T C H   R E C U R S I O N  exceeds STACK limits ******
rem VERIFY OTHER 2>nul &SETLOCAL ENABLEDELAYEDEXPANSION &IF ERRORLEVEL 1 (echo CMD extensions not available & goto :EOF)
SETLOCAL ENABLEDELAYEDEXPANSION
pushd "%~1"
>"%TEMP%\strlen.tmp" echo."%~1"
set _STRING_LENGTH=0
for %%? in (%TEMP%\strlen.tmp) do (set /A _STRING_LENGTH=%%~z? - 4)
set "_RIGHT_PADDING= "
for /L %%i in (!_STRING_LENGTH!,1,60) do set "_RIGHT_PADDING=!_RIGHT_PADDING! "
for /f "tokens=2,3" %%i in ('call git remote -v') do @if /I "%%j" equ "(push)" echo. "%~1"!_RIGHT_PADDING!   	^(%%i^)
popd
rem fix: ******  B A T C H   R E C U R S I O N  exceeds STACK limits ******
ENDLOCAL
goto :EOF