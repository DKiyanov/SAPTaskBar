@echo off
SET THEFILE=PHook.dll
echo Linking %THEFILE%
C:\lazarus\fpc\2.6.4\bin\i386-win32\ld.exe -b pei-i386 -m i386pe  --gc-sections  -s --dll --subsystem windows --entry _DLLWinMainCRTStartup   --base-file base.$$$ -o PHook.dll link.res
if errorlevel 1 goto linkend
C:\lazarus\fpc\2.6.4\bin\i386-win32\dlltool.exe -S C:\lazarus\fpc\2.6.4\bin\i386-win32\as.exe -D PHook.dll -e exp.$$$ --base-file base.$$$ 
if errorlevel 1 goto linkend
C:\lazarus\fpc\2.6.4\bin\i386-win32\ld.exe -b pei-i386 -m i386pe  -s --dll --subsystem windows --entry _DLLWinMainCRTStartup   -o PHook.dll link.res exp.$$$
if errorlevel 1 goto linkend
C:\lazarus\fpc\2.6.4\bin\i386-win32\postw32.exe --subsystem gui --input PHook.dll --stack 16777216
if errorlevel 1 goto linkend
goto end
:asmend
echo An error occured while assembling %THEFILE%
goto end
:linkend
echo An error occured while linking %THEFILE%
:end
