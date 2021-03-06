::Find and Replace script allows the user to 
::define a file path, file name and a string 
::to find and replace so as to create a new file.
::
::Original file is backed up with an added extension of *.bak, in case
::the user finds the need to go back to the original.

@echo off
::Use the path from whence the script was executed as
::the Current Working Directory
set CWD=%~dp0

::***BEGIN MODIFY BLOCK***
::The variables below should be modified to the
::files to be changed and the strings to find/replace
::Include trailing backslash in _FilePath
set _FilePath=%CWD%
set _FileExt=*.vmx
for /f "delims=" %%A in ('dir /b %_FilePath% %_FileExt%') do set _FileName=%%A
echo %_FileName%
:: set _FileName=*.vmx


::_WrkFile is the file on which the script will make
::modifications.
set _WrkFile=yes.bak
set OldStr="The string to be found and replaced, enclosed in double-quotes"
set NewStr="The new string to replace the value of OldStr, enclosed in double-quotes"
::***END MODIFY BLOCK***

::Set a variable which is used by the
::search and replace section to let us
::know if the string to be modified was
::found or not.
set _Found=Not found

SETLOCAL
SETLOCAL ENABLEDELAYEDEXPANSION

if not exist "%_FilePath%%_FileName%" goto :NotFound

::If a backup file exists, delete it
if exist "%_FilePath%%_WrkFile%" (
    echo Deleting "%_FilePath%%_WrkFile%" 
    del "%_FilePath%%_WrkFile%" >nul 2>&1
    )

echo.
echo Backing up "%_FilePath%%_FileName%"...
copy "%_FilePath%%_FileName%" "%_FilePath%%_WrkFile%" /v

::Delete the original file. No worries, we got a backup.
if exist "%_FilePath%%_FileName%" del "%_FilePath%%_FileName%"
echo.
echo Searching for %OldStr% string...
echo.
for /f "usebackq tokens=*" %%a in ("%_FilePath%%_WrkFile%") do (
    set _LineChk=%%a
    if "!_LineChk!"==%OldStr% (
        SET _Found=Found 
        SET NewStr=!NewStr:^"=! 
        echo !NewStr!
        ) else (echo %%a)
        )>>"%_FilePath%%_FileName%" 2>&1

::If we didn't find the string, rename the backup file to the original file name
::Otherwise, delete the _WorkFile as we re-created the original file when the
::string was found and replaced.
if /i "!_Found!"=="Not found" (echo !_Found! && del "%_FilePath%%_FileName%" && ren "%_FilePath%%_WrkFile%" %_FileName%) else (echo !_Found! && del "%_FilePath%%_WrkFile%")
goto :exit

:NotFound
echo.
echo File "%_FilePath%%_FileName%" missing. 
echo Cannot continue...
echo.
:: Pause script for approx. 10 seconds...
PING 127.0.0.1 -n 11 > NUL 2>&1
goto :Exit

:Exit
exit /b
