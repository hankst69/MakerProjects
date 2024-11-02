@rem validate perl:
@rem 1) for cloning qt submodules perl script
@rem 2) for opus optimization in build_qt
@rem 3) also for QNX/gperf  see https://github.com/gperftools/gperftools/issues/1429
@call "%~dp0\validate.bat" "PERL" "call perl --version" "for /f ""tokens=1,2 delims=("" %%%%i in ('call perl --version') do for /f ""tokens=1,* delims=)"" %%%%k in (""%%%%j"") do echo %%%%k" %*
