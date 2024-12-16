@call "%~dp0core\validate.bat" "PERL" "call perl --version" "for /f ""tokens=1,2 delims=("" %%%%i in ('call perl --version') do for /f ""tokens=1,* delims=)"" %%%%k in (""%%%%j"") do echo %%%%k" %*
