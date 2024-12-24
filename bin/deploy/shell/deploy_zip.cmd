@echo off

REM Get the current date and time
for /f "tokens=1-4 delims=/ " %%a in ('date /t') do set mydate=%%a-%%b-%%c
for /f "tokens=1-2 delims=: " %%a in ('time /t') do set mytime=%%a:%%b

REM Get the current Git branch name
for /f "tokens=*" %%i in ('git rev-parse --abbrev-ref HEAD') do set branch=%%i

REM Get the current Git repository name
for /f "tokens=*" %%i in ('git rev-parse --show-toplevel') do set repo=%%~nxi

REM Get the current Git commit hash
for /f "tokens=*" %%i in ('git rev-parse HEAD') do set commit=%%i

REM Get the current Git remote URL
for /f "tokens=*" %%i in ('git config --get remote.origin.url') do set remote_url=%%i

REM Create the meta.txt file
echo Branch: %branch% > meta.txt
echo Repository: %repo% >> meta.txt
echo Commit: %commit% >> meta.txt
echo Remote URL: %remote_url% >> meta.txt
echo Date: %mydate% >> meta.txt
echo Time: %mytime% >> meta.txt

echo meta.txt file created successfully.

REM Copy all files from ../scripts to ../rel
xcopy /s /i /y ..\scripts\* ..\rel\

echo Files copied from ../scripts to ../rel successfully.

REM Move the meta.txt file to ../rel/bfsuite
move meta.txt ..\rel\bfsuite\

echo meta.txt file moved to ../rel/bfsuite successfully.

REM Get the short Git commit hash
for /f "tokens=*" %%i in ('git rev-parse --short HEAD') do set short_commit=%%i

REM Create a zip file from ../rel/bfsuite
powershell Compress-Archive -Path ..\rel\bfsuite\* -DestinationPath ..\rel\bfsuite_%short_commit%.zip

echo Zip file created successfully: bfsuite_%short_commit%.zip

REM Delete the bfsuite folder in ../rel
rmdir /s /q ..\rel\bfsuite

echo bfsuite folder deleted successfully.