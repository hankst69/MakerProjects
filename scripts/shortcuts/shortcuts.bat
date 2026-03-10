@echo off
if /i "%~1" equ "--test" goto :EOF

if /i "%~1" neq "--setup" (
  setlocal EnableDelayedExpansion
  set _max_length=0
  echo shortcuts:
  for %%f in (%~dp0\*.bat) do (
    if /i "%%~nf" neq "%~n0" (
      set "_string=%%~nf"
      call :strlen _string _length
      if !_max_length! lss !_length! set _max_length=!_length!
      if !_length! leq 3 (
        set _padding=
        for /l %%i in (!_length!,1,3) do set "_padding=!_padding! "
        echo|set /p="%%~nf!_padding! : "
        call "%%~f" --shortcut-info
      )
    )
  )
  if !_max_length! gtr 3 (
    echo.
    echo applications:
    for %%f in (%~dp0\*.bat) do (
      if /i "%%~nf" neq "%~n0" (
        set "_string=%%~nf"
        call :strlen _string _length
        if !_length! gtr 3 (
          rem set _padding= 
          rem for /l %%i in (!_length!,1,!_max_length!) do set "_padding=!_padding! "
          rem echo|set /p="%%~nf!_padding! : "
          rem call "%%~f" --shortcut-info
          echo. %%~nf
        )
      )
    )
  )
  endlocal
  goto :EOF
)

:setup
pushd "%~dp0\.."
set ERRORLEVEL=
call %~nx0 --test 2>nul
if %ERRORLEVEL% neq 0 set "PATH=%PATH%;%~dp0"
popd

goto :eof
:strlen  StrVar  [RtnVar]
  setlocal EnableDelayedExpansion
  set "s=#!%~1!"
  set "len=0"
  for %%N in (4096 2048 1024 512 256 128 64 32 16 8 4 2 1) do (
    if "!s:~%%N,1!" neq "" (
      set /a "len+=%%N"
      set "s=!s:~%%N!"
    )
  )
  endlocal&if "%~2" neq "" (set %~2=%len%) else echo %len%
exit /b