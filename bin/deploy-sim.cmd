echo off

set tgt=bfsuite

set srcfolder=%DEV_BFSUITE_GIT_SRC%
set dstfolder=%DEV_SIM_SRC%

REM "Remove destination folder"
RMDIR "%dstfolder%\%tgt%" /S /Q



REM "copy files to folder"
mkdir "%dstfolder%\%tgt%"
xcopy "%srcfolder%\scripts\%tgt%" "%dstfolder%\%tgt%"  /h /i /c /k /e /r /y