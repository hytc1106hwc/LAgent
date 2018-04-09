@echo off
echo %date% %time%

set LHOME=C:\Program Files (x86)\Lua\5.3

if not exist "%LHOME%" (
	echo "creating LUA_HOME path 
	mkdir "%LHOME%"
) else (
	echo "LUA_HOME path has been created"
)

REM enter the current disk
%~d0

REM goto the path to the current bat file
cd %~sdp0

REM "copy begin"
echo "starting copy..."

REM copy clibs
echo "copy clibs directory"
xcopy /Y /H /E /S ".\clibs\*.*" "%LHOME%\clibs\"
echo "successfully copu ./clibs"

REM copy lua scripts
xcopy /Y /H /E /S ".\lua\*.*" "%LHOME%\lua\"
echo "successfully copy ./lua"

REM copy finished
echo "end copy"

pause