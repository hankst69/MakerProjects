@call "%~dp0core\generic_validate.bat" "CMAKE" "cmake --version" "for /f ""tokens=1-3 delims= "" %%%%i in ('call cmake --version') do if /I %%%%j EQU version echo %%%%k" %*
