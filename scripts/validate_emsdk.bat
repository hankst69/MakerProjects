@call "%~dp0core\generic_validate.bat" "EMSDK" "call emcc --version" "for /f ""tokens=1,5 delims= "" %%%%i in ('call emcc --version') do if ""%%%%i"" equ ""emcc"" echo %%%%j" %*
