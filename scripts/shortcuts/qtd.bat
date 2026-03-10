@if /i "%~1" equ "--shortcut-info" echo QtDesigner&goto :EOF
@echo QtDesigner %*
@"%~dp0\qtdesigner.bat" %*