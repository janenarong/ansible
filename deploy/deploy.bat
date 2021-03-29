@echo off

sc query | find "SQL Server (" > C:\deploy\instance.txt


SETLOCAL DisableDelayedExpansion
FOR /F "usebackq delims=" %%a in (`"findstr /n ^^ C:\deploy\instance.txt"`) do (
    set "myVar=%%a"
    call :processLine myVar
)
goto: eof
:processLine
SETLOCAL EnableDelayedExpansion
set "line=!%1!"
set "line=!line:*:=!"


for /f "tokens=2 delims=(" %%b in ("%line%") do (
	set db=%%b
)

for /f "tokens=1 delims=)" %%c in ("%db%") do (
	set instancename=%%c
)

echo %instancename% >> C:\deploy\instance2.txt
set instancename2=%COMPUTERNAME%\%instancename%

echo # result on %date% > C:\deploy\log\log.txt

echo -------------------- %instancename% -------------------- >> C:\deploy\log\log.txt

SETLOCAL EnableDelayedExpansion
IF %instancename% == MSSQLSERVER (	
	set code=0
	FOR %%i in (C:\deploy\script\*.sql) do (
	sqlcmd -S %COMPUTERNAME% -i "%%i" -o C:\deploy\result\%%~ni_result.txt  -E
	if not %errorlevel%==0 ( echo Msq >> C:\deploy\result\%%~ni_result.txt)
		for /f "tokens=*" %%d IN ('findstr /m /c:"Sqlcmd: Error:" C:\deploy\result\%%~ni_result.txt') do (
		set code=1
		echo %instancename% script:%%~ni error >> C:\deploy\log\log.txt
		del C:\deploy\instance.txt
		del C:\deploy\instance2.txt
		EXIT 1
		)
		for /f "tokens=*" %%d IN ('findstr /m "Msg" C:\deploy\result\%%~ni_result.txt') do (
		set code=1
		echo %instancename% script:%%~ni error >> C:\deploy\log\log.txt
		del C:\deploy\instance.txt
		del C:\deploy\instance2.txt
		EXIT 1
		)
	IF !code!==0 (echo %instancename% script:%%~ni complete >> C:\deploy\log\log.txt )
	)
) ELSE (
	set code=0
	FOR %%i in (C:\deploy\script\*.sql) do (
	sqlcmd -S %instancename2% -i "%%i" -o C:\deploy\result\%%~ni_result.txt -E
	if not %errorlevel%==0 ( echo Msg >> C:\deploy\result\%%~ni_result.txt)
		for /f "tokens=*" %%d IN ('findstr /m /c:"Sqlcmd: Error:" C:\deploy\result\%%~ni_result.txt') do (
		set code=1
		echo %instancename% script:%%~ni error >> C:\deploy\log\log.txt
		del C:\deploy\instance.txt
		del C:\deploy\instance2.txt
		EXIT 1
		)
		for /f "tokens=*" %%d IN ('findstr /m "Msg" C:\deploy\result\%%~ni_result.txt') do (
		set code=1
		echo %instancename% script:%%~ni error >> C:\deploy\log\log.txt
		del C:\deploy\instance.txt
		del C:\deploy\instance2.txt
		EXIT 1
		)
	IF !code!==0 (echo %instancename% script:%%~ni complete >> C:\deploy\log\log.txt )
	)
	
	 
)
ENDLOCAL

	
ENDLOCAL
del C:\deploy\instance.txt
del C:\deploy\instance2.txt