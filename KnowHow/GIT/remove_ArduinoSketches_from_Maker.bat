@echo off

call git_rm_permanent    "https://github.com/hankst69/MakerProjects" "espBode_refactoring1_20230926.7z" --forced --reset
call git_rm_permanent    "https://github.com/hankst69/MakerProjects" "espBode_refactoring2_20230929.7z" --forced

call git_rmdir_permanent "https://github.com/hankst69/MakerProjects" "ArduinoSketches"
call git_rmdir_permanent "https://github.com/hankst69/MakerProjects" "esp32Cam" --forced
call git_rmdir_permanent "https://github.com/hankst69/MakerProjects" "unoR3-projects" --forced

echo.
echo.
echo.
echo -------------------------------------------------------
rem echo. perform "git push --all --force" to update the remote repository with modified history
echo perfom "git push --force --mirror origin" to update the remote repository with modified history
echo -------------------------------------------------------

