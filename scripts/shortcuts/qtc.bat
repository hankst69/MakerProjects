@if /i "%~1" equ "--shortcut-info" echo QtCreator&goto :EOF
@echo QtCreator %*
@"%~dp0\qtcreator.bat" %*