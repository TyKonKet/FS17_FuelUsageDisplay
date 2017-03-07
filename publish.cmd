@ECHO OFF
SETLOCAL ENABLEEXTENSIONS
SET my_path=%~dp0
SET mod_path=%1
SET mod_path=%mod_path:"=%
FOR %%f IN (%mod_path%) DO SET mod_name=%%~nxf
ECHO ############################## Starting publish of %mod_name% ##############################
SET mod_path_src=%mod_path%\src
SET mod_path_out=%mod_path%\out
SET fs17_mods_path=%USERPROFILE%\Documents\My Games\FarmingSimulator2017\mods\
SET fs17_mod_path=%fs17_mods_path%%mod_name%
START /WAIT /B build.cmd %1
DEL "%mod_path_out%\%mod_name%.zip"
PUSHD "%mod_path_src%"
"C:\Program Files\WinRAR\winrar" A -r ..\out\%mod_name%.zip *.*
POPD
RMDIR /S /Q "%fs17_mod_path%\"
COPY "%mod_path_out%\%mod_name%.zip" "%fs17_mods_path%%mod_name%.zip"
ECHO ################################### %mod_name% published ###################################
EXIT