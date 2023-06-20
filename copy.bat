@echo off
mkdir release 2>nul

set SCRIPT_NAME=%1

:: Concatenate VERSION and %SCRIPT_NAME%.lua into a temporary file
(
  type VERSION
  echo.
  type %SCRIPT_NAME%.lua
) > temp_version.txt

:: Move the temporary file to overwrite %SCRIPT_NAME%.lua
move /Y temp_version.txt %SCRIPT_NAME%.lua

:: Move and copy the modified %SCRIPT_NAME%.lua
move /Y %SCRIPT_NAME%.lua release\%SCRIPT_NAME%.lua
copy /Y release\%SCRIPT_NAME%.lua "%APPDATA%\Stand\Lua Scripts"