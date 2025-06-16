@echo off

rem ===================================================
rem Author: kevin-at-f5-dot-com
rem ===================================================

set processpath=
set certificate=
set privatekey=
set crl=

if "%1" equ "" goto INFO
if "%2" equ "" goto INFO

if NOT EXIST CRLS\%2 mkdir CRLS\%2
if NOT EXIST PROCESS\%2\index.txt echo 2>PROCESS\%2\index.txt >nul
if NOT EXIST PROCESS\%2\serial echo 01>PROCESS\%2\serial

if exist CONFIGS\openssl_local echo Y |del CONFIGS\openssl_local
echo PROCESSPATH = %2 >> CONFIGS\openssl_local
echo CERTIFICATE = .\\CA\\%2.cer >> CONFIGS\openssl_local
echo PRIVATE_KEY = .\\CA\\%2.key >> CONFIGS\openssl_local
echo CRL = null >> CONFIGS\openssl_local
type CONFIGS\openssl.CRL.cnf >> CONFIGS\openssl_local

openssl ca -gencrl -config CONFIGS\openssl_local -out CRLS\%2\%1.crl.pem

echo y |del CONFIGS\openssl_local

echo.
echo.
set /P if_der=Do you want to create a DER version? y or n:
if "%if_der%" equ "y" openssl crl -in CRLS\%2\%1.crl.pem -outform DER -out CRLS\%2\%1.crl

echo.
echo.
echo Complete.
goto end

:INFO
echo ####### Certificate Revocation List Creator #####
echo #
echo # Description: creates certificate revocation lists.
echo #
echo # Usage:  make.crl.cmd ^<CRL name^> ^<CA Cert full name^> 
echo #
echo #   Ex. make.crl.cmd crl.alpha.com ca.alpha.com
echo #
echo #######
goto end

:end
