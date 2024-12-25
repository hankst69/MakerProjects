@call "%~dp0core\generic_validate.bat" "FLEX" "flex --version" "for /f ""tokens=1,2 delims= "" %%%%i in ('call flex --version') do if /I %%%%i EQU win_flex.exe echo %%%%j" %*
