@call "%~dp0core\generic_validate.bat" "MAKE" "make --version" "for /f ""tokens=1,2,* delims= "" %%%%i in ('call make --version') do if /I %%%%i EQU gnu if /I %%%%j EQU make echo %%%%k" %*
