@echo off
call :List_Git_Repos_in_Dir "%~dp0"
goto :EOF

:List_Git_Repos_in_Dir
for /D %%f in (%~1*) do if exist "%%~f\.git" (call :Dump_Git_Repo "%%f") else (call :List_Git_Repos_in_Dir "%%f\")
goto :EOF

:Dump_Git_Repo
pushd "%~1"
for /f "tokens=2,3" %%i in ('call git remote -v') do @if /I "%%j" equ "(push)" echo. "%~1" 		 ^(%%i^)
popd
goto :EOF