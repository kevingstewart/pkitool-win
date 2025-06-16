@echo off

rem ===================================================
rem Author: kevin-at-f5-dot-com
rem ===================================================

set processpath=
set orgunitname=
set commonnamestring=
set commonname=
set SHA=
set RSA=

if "%1" equ "" goto INFO

if NOT EXIST PROCESS\%1 mkdir PROCESS\%1

if NOT EXIST PROCESS\%1\index.txt echo 2>PROCESS\%1\index.txt >nul
if NOT EXIST PROCESS\%1\serial echo 01>PROCESS\%1\serial

if exist CONFIGS\openssl_local echo Y |del CONFIGS\openssl_local
echo PROCESSPATH = %1 >> CONFIGS\openssl_local
echo ORGUNITNAME = Certificate Authority >> CONFIGS\openssl_local
echo COMMONNAMESTRING = Common Name (CN=) >> CONFIGS\openssl_local
echo COMMONNAME = %1 >> CONFIGS\openssl_local
type CONFIGS\openssl.CAROOT.cnf >> CONFIGS\openssl_local

if "%2" equ "" echo "Setting hashing algorithm to SHA1" && set SHA="sha1"
if "%2" equ "sha1" echo "Setting hashing algorithm to SHA1" && set SHA="sha1"
if "%2" equ "sha256" echo "Setting hashing algorithm to SHA256" && set SHA="sha256"
if "%SHA%" equ "" echo Usage:  make.caroot.cmd ^<certificate fully qualified name^> [[sha1 or sha256] [rsa1024 or rsa2048 or rsa4096 or rsa8192]] && goto end

if "%3" equ "" echo "Setting encryption algorithm to RSA2048" && set RSA="rsa:2048"
if "%3" equ "rsa1024" echo "Setting encryption algorithm to RSA1024" && set RSA="rsa:1024"
if "%3" equ "rsa2048" echo "Setting encryption algorithm to RSA2048" && set RSA="rsa:2048"
if "%3" equ "rsa4096" echo "Setting encryption algorithm to RSA4096" && set RSA="rsa:4096"
if "%3" equ "rsa8192" echo "Setting encryption algorithm to RSA8192" && set RSA="rsa:8192"
if "%RSA%" equ "" echo Usage:  make.caroot.cmd ^<certificate fully qualified name^> [[sha1 or sha256] [rsa2048 or rsa1024 or rsa4096 or rsa8192]] && goto end

openssl req -new -x509 -%SHA% -days 1024 -newkey %RSA% -keyout CA\%1.key -out CA\%1.cer -config CONFIGS\openssl_local

echo y |del CONFIGS\openssl_local

echo.
echo.
echo Complete.
echo %1.cer and %1.key have been created and are in the CA folder
goto end

:INFO
echo ####### Self-Signed Root CA Certificate Creator #####
echo #
echo # Description: creates a self-signed root CA certificate. Customization of the CA certificate is provided
echo #     in the CONFIGS\openssl.CAROOT.cnf file in the [ v3_ca ] section.
echo #
echo # Usage:  make.caroot.cmd ^<certificate fully qualified name^> [[sha1 or sha256] [rsa2048 or rsa1024 or rsa4096 or rsa8192]] 
echo #
echo #    Ex. make.caroot.cmd ca.alpha.com
echo #
echo #######
goto end

:end
