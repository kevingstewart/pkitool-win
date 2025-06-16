@echo off

if "%1" equ "" goto INFO

if "%1" equ "ca" (
	if "%2" equ "rel" (
		echo.
		for /f "tokens=1,2,3,4* delims=" %%i in ('dir /b CA\*.cer') do call :LISTCAREL %%i
		goto end
	) else (
		echo.
		for /f "tokens=1,2,3,4* delims=" %%i in ('dir /b CA\*.cer') do call :LISTCAONLY %%i
		goto end
	)
)


:LISTCAONLY
rem ## get cert short name
set shortname=%1
set shortname=%shortname:.cer=%
echo %shortname%
goto end

:LISTCAREL
set parent=
rem ## get cert short name
set shortname=%1
set shortname=%shortname:.cer=%
rem ## find subject
for /f "tokens=1,2,3* delims=" %%a in ('openssl x509 -in CA\%1 -noout -subject') do set subject=%%a
set subject=%subject:CN=@%
for /f "tokens=1,2* delims=@" %%b in ('echo %subject%') do set subject=%%c
rem ## find parent
for /f "tokens=1,2,3* delims=" %%a in ('openssl x509 -in CA\%1 -noout -issuer') do set parent=%%a
set parent=%parent:CN=@%
for /f "tokens=1,2* delims=@" %%b in ('echo %parent%') do set parent=%%c
rem ## compare
if %subject% equ %parent% (
	echo %shortname%     [PARENT = self-signed]
) else (
    echo %shortname%     [PARENT =%parent%]
)
goto end

:INFO
echo.
echo Usage: 
echo      list ca          (list CAs)
echo      list ca rel      (list CAs and relationships)
echo.
goto end

:end