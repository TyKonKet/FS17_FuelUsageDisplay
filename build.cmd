@ECHO off
SETLOCAL ENABLEEXTENSIONS
SET my_path=%~dp0
SET mod_path=%1
SET mod_path=%mod_path:"=%
for %%f in (%mod_path%) do SET mod_name=%%~nxf
ECHO ############################## Starting build of %mod_name% ##############################
SET mod_path_src=%mod_path%\src
SET mod_path_out=%mod_path%\out
SET fs17_mods_path=%USERPROFILE%\Documents\My Games\FarmingSimulator2017\mods\
SET fs17_mod_path=%fs17_mods_path%%mod_name%
RMDIR /S /Q "%fs17_mod_path%\"
DEL "%fs17_mods_path%%mod_name%.zip"
XCOPY /B "%mod_path_src%" "%fs17_mod_path%\"
ECHO #################################### %mod_name% built ####################################
EXIT