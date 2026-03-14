@if /i "%~1" equ "--shortcut-info" echo build&goto :EOF
@::@echo.WScript.CreateObject("WScript.Shell").SendKeys "{UP}{LEFT}{END} --> build %*">"%TEMP%\_up_end_vb_script.vbs"
@::@cscript /Nologo /B /U "%TEMP%\_up_end_vb_script.vbs"
@::@echo.%cd%^>build %*
@"%~dp0\build.bat" %*
