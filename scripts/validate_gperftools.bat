@rem validate gperftools:
@call "%~dp0validate.bat" "GPERFTOOLS" "tcmalloc_minimal_unittest --gtest_list_tests" "call echo 0.0.0" %*
