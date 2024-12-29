goto :EOF
cd %~dp0\..\Qt\qt_sources_6.6.3\qttools
call 7z a ..\..\..\packages\qt663_qttools-llvm20-patch.7z src/linguist/lupdate/clangtoolastreader.cpp src/linguist/lupdate/clangtoolastreader.h src/linguist/lupdate/cpp_clang.h src/linguist/lupdate/lupdatepreprocessoraction.cpp src/linguist/lupdate/lupdatepreprocessoraction.h