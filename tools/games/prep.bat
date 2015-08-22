@echo off
if "%1"==""  goto end
for /F %%a in ("%1") do set nom=%%~na
..\cc2asm.exe %1 %nom%.bin && ..\cvt-chip.exe -pAVR %nom%.bin && copy %nom%.c ..\..\..\ /y  && copy %nom%.h ..\..\..\ /y

:end

