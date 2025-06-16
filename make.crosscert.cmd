@echo off

rem ===================================================
rem Author: kevin-at-f5-dot-com
rem ===================================================

set processpath=
set orgname=
set orgunitname=
set commonnamestring=
set commonname=

if "%1" equ "" goto INFO
if "%2" equ "" goto INFO
if NOT EXIST CA\%1.cer echo CA certificate %1 does not exist. && goto end
if NOT EXIST CA\%1.key echo CA key %1 does not exist. && goto end
if NOT EXIST CA\%2.cer echo CA certificate %2 does not exist. && goto end
if NOT EXIST CA\%2.key echo CA key %2 does not exist. && goto end

if NOT EXIST PROCESS\%1 mkdir PROCESS\%1
if NOT EXIST PROCESS\%1\serial echo 01>PROCESS\%1\serial
if NOT EXIST PROCESS\%1\index.txt echo 2>PROCESS\%1\index.txt >nul

set myvar=
for /f "delims=" %%i in ('type PROCESS\%1\serial') do set myvar=%%i
if "%myvar%" equ "" echo 01>PROCESS\%1\serial
set myvar=
for /f "delims=" %%i in ('type PROCESS\%2\serial') do set myvar=%%i
if "%myvar%" equ "" echo 01>PROCESS\%2\serial

for /f "tokens=1,2,3,4,5* delims=O=," %%i in ('openssl x509 -in CA\%1.cer -text ^|find "O=" ^|find "Subject"') do set orgname=%%l

if exist CONFIGS\openssl_local echo Y |del CONFIGS\openssl_local
echo PROCESSPATH = %1 >> CONFIGS\openssl_local
echo ORGNAME = %orgname% >> CONFIGS\openssl_local
echo ORGUNITNAME = Certificate Authority >> CONFIGS\openssl_local
echo COMMONNAMESTRING = Common Name (CN=) >> CONFIGS\openssl_local
echo COMMONNAME = %1 >> CONFIGS\openssl_local
type CONFIGS\openssl.CROSSCERT.cnf >> CONFIGS\openssl_local

openssl req -new -config CONFIGS\openssl_local -key CA\%1.key -out CA\%1.csr
openssl x509 -req -CA CA\%2.cer -CAkey CA\%2.key -in CA\%1.csr -CAserial PROCESS\%2\serial -extfile CONFIGS\openssl_local -extensions v3_ca -out CA\x-%1.crt

echo y |del CA\%1.csr
echo y |del CONFIGS\openssl_local

echo.
echo.
echo Complete.
goto end

:INFO
echo ####### Cross-Certification Utility #####
echo #
echo # Description: allows for the cross-certificate of CA certificates. Customization of the cross-certified
echo #     certificate is provided in the CONFIGS\openssl.CROSSCERT.cnf file in the [ v3_ca] section.
echo #
echo # Usage:  make.crosscert.cmd ^<signee certificate^> ^<signer certificate^> 
echo #
echo #   Ex. make.crosscert.cmd ca.alpha.com ca.bravo.com
echo #
echo #######
goto end

:end
