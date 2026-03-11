@if /i "%~1" equ "--shortcut-info" echo git commit&goto :EOF
@echo git commit %*
@if "%~1" equ "" @call git commit
@if "%~1" equ "" goto :EOF
@:: Remove quotes
@SET _string=###%*###
@SET _string=%_string:"###=%
@SET _string=%_string:###"=%
@SET _string=%_string:###=%
@call git commit -m "%_string%"
@set _string=
