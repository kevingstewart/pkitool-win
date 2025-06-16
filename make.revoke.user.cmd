@echo off

rem ===================================================
rem Author: k.stewart@f5.com
rem ===================================================

set processpath=
set certificate=
set privatekey=
set crl=

if "%1" equ "" goto INFO
if "%2" equ "" goto INFO
if "%3" equ "" goto INFO

if NOT EXIST CRLS\%2 mkdir CRLS\%2

if exist CONFIGS\openssl_local echo Y |del CONFIGS\openssl_local
echo PROCESSPATH = %2 >> CONFIGS\openssl_local
echo CERTIFICATE = .\\CA\\%2.cer >> CONFIGS\openssl_local
echo PRIVATE_KEY = .\\CA\\%2.key >> CONFIGS\openssl_local
echo CRL = .\\CRLS\\%2\\%3.crl >> CONFIGS\openssl_local
type CONFIGS\openssl.REVOKEUSER.cnf >> CONFIGS\openssl_local

openssl ca -config CONFIGS\openssl_local -revoke USERCERTS\%2\%1.crt
openssl ca -gencrl -config CONFIGS\openssl_local -out CRLS\%2\%3.crl.pem
openssl crl -in CRLS\%2\%3.crl.pem -outform DER -out CRLS\%2\%3.crl

echo y |del CONFIGS\openssl_local

echo.
echo.
echo Complete.
echo Certificate for user %1 has been marked revoked in CA %2 and a new CRL has been created in the CRL folder
goto end

:INFO
echo ####### User Certificate Revocation Utility #####
echo #
echo # Description: revokes user certificates. 
echo #
echo # Usage:  make.revoked.cmd ^<certificate name^> ^<CA Cert full name^> ^<CRL full name^> 
echo #
echo #   Ex. make.revoked.cmd joe.user ca.alpha.com
echo #
echo #######
goto end

:end