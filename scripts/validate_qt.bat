@call "%~dp0core\generic_validate.bat" "QT" "uic.exe --version" "for /f ""tokens=1,* delims= "" %%%%i in ('call uic.exe --version') do if /I %%%%i EQU uic echo %%%%j" %*
