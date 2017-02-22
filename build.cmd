@ECHO off
SETLOCAL ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION
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
MKDIR "%fs17_mod_path%"
PUSHD "%mod_path_src%"
SET /a count = 0
for /r %%a in (*) do (
    COPY "%%a" "%fs17_mod_path%\%%~nxa" > nul
    SET /a count += 1
)
echo Copied !count! file(s)
POPD
ECHO #################################### %mod_name% built ####################################
ENDLOCAL
EXIT