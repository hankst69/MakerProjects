@echo off
if exist "%~dp0.nanovna-saver\Scripts\NanoVNASaver.exe" if exist "%~dp0nanovna-saver\src\NanoVNASaver\Windows\ui\about.py" goto :Start

cd /d "%~dp0"
rem if exist "nanovna-saver" rmdir /s /q "nanovna-saver" 
git clone -q https://github.com/NanoVNA-Saver/nanovna-saver.git
python -m venv .nanovna-saver
call .nanovna-saver\Scripts\activate
python -m pip install --upgrade pip

cd nanovna-saver
call python -m pip install -e .
rem D:\GIT\HAM\nanovna-saver\src\NanoVNASaver\Windows\ui>pyside6-rcc.exe main.qrc -g python -o main_rc.py
echo.
echo pyside6-rcc.exe .\src\NanoVNASaver\Windows\ui\main.qrc -g python -o .\src\NanoVNASaver\Windows\ui\main_rc.py
pyside6-rcc.exe .\src\NanoVNASaver\Windows\ui\main.qrc -g python -o .\src\NanoVNASaver\Windows\ui\main_rc.py
echo pyside6-uic.exe .\src\NanoVNASaver\Windows\ui\about.ui -g python -o .\src\NanoVNASaver\Windows\ui\about.py
pyside6-uic.exe .\src\NanoVNASaver\Windows\ui\about.ui -g python -o .\src\NanoVNASaver\Windows\ui\about.py
echo.
set "PYTHONPATH=%~dp0nanovna-saver\src\NanoVNASaver\Windows\ui"
python -m pip install -e .
goto :Start


:Start
cd /d "%~dp0"
call "%~dp0.nanovna-saver\Scripts\activate"
"%~dp0.nanovna-saver\Scripts\NanoVNASaver.exe"
deactivate