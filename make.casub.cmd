@echo off

rem ===================================================
rem Author: kevin-at-f5-dot-com
rem ===================================================

set processpath=
set orgunitname=
set orgname=
set commonnamestring=
set commonname=
set SHA=
set RSA=

if "%1" equ "" goto INFO
if "%2" equ "" goto INFO
if NOT EXIST CA\%2.cer echo CA %2 does not exist. && goto end
if NOT EXIST CA\%2.key echo CA %2 does not exist. && goto end

if NOT EXIST PROCESS\%1 mkdir PROCESS\%1

if NOT EXIST PROCESS\%1\index.txt echo 2>PROCESS\%1\index.txt >nul
if NOT EXIST PROCESS\%1\serial echo 01>PROCESS\%1\serial

for /f "tokens=1,2,3,4,5* delims=O=," %%i in ('openssl x509 -in CA\%2.cer -text ^|find "O=" ^|find "Subject"') do set orgname=%%l

if exist CONFIGS\openssl_local echo Y |del CONFIGS\openssl_local
echo PROCESSPATH = %1 >> CONFIGS\openssl_local
echo ORGNAME = %orgname% >> CONFIGS\openssl_local
echo ORGUNITNAME = Subordinate Authority >> CONFIGS\openssl_local
echo COMMONNAMESTRING = Common Name (CN=server.domain.com) >> CONFIGS\openssl_local
echo COMMONNAME = %1 >> CONFIGS\openssl_local
type CONFIGS\openssl.CASUB.cnf >> CONFIGS\openssl_local

if "%3" equ "" echo "Setting hashing algorithm to SHA1" && set SHA="sha1"
if "%3" equ "sha1" echo "Setting hashing algorithm to SHA1" && set SHA="sha1"
if "%3" equ "sha256" echo "Setting hashing algorithm to SHA256" && set SHA="sha256"
if "%SHA%" equ "" echo Usage:  make.casub.cmd ^<certificate fqdn^> ^<CA Cert Name^> [[sha1 or sha256] [rsa1024 or rsa2048 or rsa4096 or rsa8192]] && goto end

if "%4" equ "" echo "Setting encryption algorithm to RSA2048" && set RSA="2048"
if "%4" equ "rsa1024" echo "Setting encryption algorithm to RSA1024" && set RSA="1024"
if "%4" equ "rsa2048" echo "Setting encryption algorithm to RSA2048" && set RSA="2048"
if "%4" equ "rsa4096" echo "Setting encryption algorithm to RSA4096" && set RSA="4096"
if "%4" equ "rsa8192" echo "Setting encryption algorithm to RSA8192" && set RSA="8192"
if "%RSA%" equ "" echo Usage:  make.casub.cmd ^<certificate fqdn^> ^<CA Cert Name^> [[sha1 or sha256] [rsa2048 or rsa1024 or rsa4096 or rsa8192]] && goto end

openssl genrsa -out CA\%1.key %RSA%
openssl req -new -config CONFIGS\openssl_local -days 1024 -key CA\%1.key -out CA\%1.csr
openssl x509 -req -%SHA% -days 1024 -CA CA\%2.cer -CAkey CA\%2.key -in CA\%1.csr -CAserial PROCESS\%1\serial -extfile CONFIGS\openssl_local -extensions v3_ca -out CA\%1.cer

echo y |del CA\*.csr
echo y |del CONFIGS\openssl_local

echo.
echo.
echo Complete.
echo %1.cer and %1.key have been created and are in the CA folder
goto end

:INFO
echo ####### Subordinate CA Certificate Creator #####
echo #
echo # Description: creates subordinate CA certificates. Customization of the subordinate certificate is
echo #     provided in the CONFIGS\openssl.CASUB.cnf file in the [ v3_ca ] section.
echo #
echo # Usage:  make.casub.cmd ^<certificate fqdn^> ^<CA Cert Name^> [[sha1 or sha256] [rsa2048 or rsa1024 or rsa4096 or rsa8192]] 
echo #
echo #   Ex. make.casub.cmd sub-ca1.alpha.com ca.alpha.com
echo #
echo #######
goto end

:end
