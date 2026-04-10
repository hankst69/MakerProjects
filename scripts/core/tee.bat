@echo off  
:: Usage: <command> | tee.bat <output_file>  
set "output_file=%1"  
:: Read input line by line, echo to console, and append to file  
for /f "delims=" %%i in ('more') do (
  echo %%i
  echo %%i>>"%output_file%"
)
