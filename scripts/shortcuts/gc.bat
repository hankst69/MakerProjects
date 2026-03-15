@if /i "%~1" equ "--shortcut-info" echo git commit&goto :EOF
@echo off
if "%~1" equ "" (
  echo about to commit without comment ^(editor will open - just close without changes to abort commit^)
  pause
  echo.%cd%^>git commit
  call git commit
  goto :EOF
)
:: Remove quotes
@SET _string=###%*###
@SET _string=%_string:"###=%
@SET _string=%_string:###"=%
@SET _string=%_string:###=%
echo.%cd%^>git commit -m "%_string%"
call git commit -m "%_string%"
set _string=
