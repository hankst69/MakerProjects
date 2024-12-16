@call "%~dp0core\validate.bat" "EMSDK" "call emcc --version" "for /f ""tokens=1,10 delims= "" %%%%i in ('call emcc --version') do if ""%%%%i"" equ ""emcc"" echo %%%%j" %*
