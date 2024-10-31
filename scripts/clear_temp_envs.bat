@echo off
echo @echo off>"%TEMP%\_clear_temp_env.bat"
cmd /Q /E:ON /V:ON /S /C "for /f "tokens=1,* delims==" %%v in ('set _') do set "__VVAL=%%v" & if "!__VVAL:~0,2!" neq "__" echo set %%v=>>"%TEMP%\_clear_temp_env.bat""
rem type "%TEMP%\_clear_temp_env.bat"
call "%TEMP%\_clear_temp_env.bat"
del "%TEMP%\_clear_temp_env.bat"
