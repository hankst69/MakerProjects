@rem https://emscripten.org/docs/getting_started/downloads.html
@echo off
call "%~dp0\maker_env.bat" %*

set "_EMSDK_START_DIR=%cd%"

rem -- clone EMSDK
call "%MAKER_BUILD%\clone_emsdk.bat" %*
rem defines: _EMSDK_DIR
rem defines: _EMSDK_BIN_DIR
rem defines: _EMSDK_VERSION
if "%_EMSDK_DIR%" EQU "" (echo error: cloning EMSDK &goto :EOF)
if not exist "%_EMSDK_DIR%" (echo error: cloning EMSDK &goto :EOF)
if "%_EMSDK_BIN_DIR%" EQU "" (echo error: cloning EMSDK &goto :EOF)
if not exist "%_EMSDK_BIN_DIR%" (echo error: cloning EMSDK &goto :EOF)
if "%_EMSDK_VERSION%" EQU "" (echo error: cloning EMSDK &goto :EOF)


rem -- ensure python is available
call "%MAKER_BUILD%\validate_python.bat"
if %ERRORLEVEL% NEQ 0 goto :exit_script


rem -- build EMSK
pushd "%_EMSDK_BIN_DIR%"
if exist "%_EMSDK_BIN_DIR%\upstream\emscripten\emcc.bat" echo EMSDK %_EMSDK_VERSION% INSTALL already done &goto :emsdk_install_done

rem # Fetch the latest version of the emsdk (not needed the first time you clone)
call git pull

rem # Download and install the latest SDK tools.
call emsdk.bat install %_EMSDK_VERSION%

:emsdk_install_done
rem # Make the SDK "active" for the current user. (writes .emscripten file)
call emsdk.bat activate %_EMSDK_VERSION%
rem 
rem Next steps:
rem - Consider running `emsdk activate` with --permanent or --system
rem   to have emsdk settings available on startup.
rem Adding directories to PATH:
rem PATH += D:\GIT\han\MakerProjects\Emsdk\latest
rem PATH += D:\GIT\han\MakerProjects\Emsdk\latest\node\18.20.3_64bit\bin
rem PATH += D:\GIT\han\MakerProjects\Emsdk\latest\upstream\emscripten
rem 
rem Setting environment variables:
rem PATH = D:\GIT\han\MakerProjects\Emsdk\latest;D:\GIT\han\MakerProjects\Emsdk\latest\node\18.20.3_64bit\bin;D:\GIT\han\MakerProjects\Emsdk\latest\upstream\emscripten;C:\Users\hankstr6\AppData\Local\Temp\DevShell-TLS-VS19-PYTHON-PATH-MakerShellVS19;C:\Python\Python38\Scripts;C:\Python\Python38;C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise\Common7\IDE\Extensions\Microsoft\IntelliCode\CLI;C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise\VC\Tools\MSVC\14.29.30133\bin\HostX86\x86;C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise\Common7\IDE\VC\VCPackages;C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise\Common7\IDE\CommonExtensions\Microsoft\TestWindow;C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise\Common7\IDE\CommonExtensions\Microsoft\TeamFoundation\Team Explorer;C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise\MSBuild\Current\bin\Roslyn;C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise\Team Tools\Performance Tools;C:\Program Files (x86)\Microsoft Visual Studio\Shared\Common\VSPerfCollectionTools\vs2019\;C:\Program Files (x86)\Microsoft SDKs\Windows\v10.0A\bin\NETFX 4.8 Tools\;C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise\Common7\Tools\devinit;C:\Program Files (x86)\Windows Kits\10\bin\10.0.22621.0\x86;C:\Program Files (x86)\Windows Kits\10\bin\x86;C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise\MSBuild\Current\Bin;C:\Windows\Microsoft.NET\Framework\v4.0.30319;C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise\Common7\IDE\;C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise\Common7\Tools\;C:\GIT\han_scripts\Tools\..;C:\Program Files\Zulu\zulu-8-jre\bin\;C:\Program Files (x86)\Zulu\zulu-8-jre\bin\;C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v12.5\bin;C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v12.5\libnvvp;C:\Program Files\IcedTeaWeb\WebStart\bin;C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v12.2\bin;C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v12.2\libnvvp;C:\Program Files (x86)\Common Files\Intel\Shared Libraries\redist\ia32\mpirt;C:\Program Files (x86)\Common Files\Intel\Shared Libraries\redist\ia32\compiler;C:\WINDOWS\system32;C:\WINDOWS;C:\WINDOWS\System32\Wbem;C:\WINDOWS\System32\WindowsPowerShell\v1.0\;C:\WINDOWS\System32\OpenSSH\;C:\Program Files\Microsoft SQL Server\130\Tools\Binn\;C:\Program Files (x86)\NVIDIA Corporation\PhysX\Common;C:\Program Files\Microsoft SQL Server\150\Tools\Binn\;C:\Program Files\dotnet\;C:\Program Files (x86)\Windows Kits\10\Windows Performance Toolkit\;C:\Program Files\PuTTY\;C:\Program Files\NVIDIA Corporation\Nsight Compute 2024.2.1\;C:\Python\Python38\Scripts\;C:\Python\Python38\;C:\Users\hankstr6\AppData\Local\Microsoft\WindowsApps;C:\Users\hankstr6\AppData\Local\Programs\Git\cmd;C:\GIT\han_scripts\Tools\cygwinmin;C:\Program Files\Notepad++;C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise\Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\bin;C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise\Common7\IDE\CommonExtensions\Microsoft\CMake\Ninja;C:\Users\hankstr6\AppData\Local\Programs\NuGetCLI\;C:\Users\hankstr6\AppData\Local\Programs\strawberry-perl-5.40.0.1-64bit-portable\perl\bin
rem EMSDK = D:/GIT/han/MakerProjects/Emsdk/latest
rem EMSDK_NODE = D:\GIT\han\MakerProjects\Emsdk\latest\node\18.20.3_64bit\bin\node.exe
rem EMSDK_PYTHON = D:\GIT\han\MakerProjects\Emsdk\latest\python\3.9.2-nuget_64bit\python.exe
rem JAVA_HOME = D:\GIT\han\MakerProjects\Emsdk\latest\java\8.152_64bit
rem Clearing existing environment variable: EMSDK_PY
rem The changes made to environment variables only apply to the currently running shell instance. Use the 'emsdk_env.bat' to re-enter this environment later, or if you'd like to register this environment permanently, rerun this command with the option --permanent.
popd


rem set llvm/clang
call "%MAKER_BUILD%\validate_llvm.bat" --no_errors
if %ERRORLEVEL% EQU 0 goto :add_llvm_done
:add_llvm_emsdk
goto :add_llvm_end
if not exist "%LLVM_INSTALL_DIR%\clang.exe" goto :add_llvm_end
set "LLVM_INSTALL_DIR=%_EMSDK_BIN_DIR%\upstream\bin"
set "PATH=%PATH%;%LLVM_INSTALL_DIR%"
:add_llvm_done
call clang --version
call clang++ --version
:add_llvm_end

echo.
echo.
call wasm32-clang --version
echo.
call wasm32-wasi-clang --version
echo.
call wasm2js --version
echo.
call emcc --version
rem call em++ --version

:exit_script
rem cd "%_EMSDK_BIN_DIR%"
cd /d "%_EMSDK_START_DIR%"
goto :EOF
