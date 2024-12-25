@call "%~dp0core\generic_validate.bat" "BISON" "bison --version" "for /f ""tokens=1-4 delims= "" %%%%i in ('call bison --version') do if /I %%%%i EQU bison echo %%%%l" %*
