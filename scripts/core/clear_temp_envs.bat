@echo off
set "__VPATTERN__=%~1"
if "%__VPATTERN__%" equ "" set "__VPATTERN__=_"
echo @echo off>"%TEMP%\_clear_temp_env.bat"
cmd /Q /E:ON /V:ON /S /C "for /f "tokens=1,* delims==" %%v in ('set %__VPATTERN__%') do set "__VNAME__=%%v" & if "!__VNAME__:~0,2!" neq "__" echo set %%v=>>"%TEMP%\_clear_temp_env.bat""
set __VPATTERN__=
set __VNAME__=
rem type "%TEMP%\_clear_temp_env.bat"
call "%TEMP%\_clear_temp_env.bat"
del "%TEMP%\_clear_temp_env.bat"
