@call "%~dp0core\generic_validate.bat" "CMAKE" """%QT_CMAKE%"" --version" "for /f ""tokens=1-3 delims= "" %%%%i in ('call "%QT_CMAKE%" --version') do if /I %%%%j EQU version echo %%%%k" %*
