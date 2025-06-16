@echo off

rem ===================================================
rem Author: k.stewart@f5.com
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

if NOT EXIST SERVERCERTS\%2 mkdir SERVERCERTS\%2
if NOT EXIST PROCESS\%2\index.txt echo 2>PROCESS\%2\index.txt >nul
if NOT EXIST PROCESS\%2\serial echo 01>PROCESS\%2\serial

rem : consume the certificate policies from the signing CA for this certificate
for /f "tokens=1,2,3,4,5* delims=O=," %%i in ('openssl x509 -in CA\%2.cer -text ^|find "O=" ^|find "Subject"') do set orgname=%%l
set certPolicy=
for /f "tokens=1,2,3* delims= " %%i in ('openssl x509 -in CA\%2.cer -noout -text ^|find "Policy: "') do call :CERTPOLICYBUILD %%j
set certPolicy=%certPolicy:~1%

if exist CONFIGS\openssl_local echo Y |del CONFIGS\openssl_local
echo PROCESSPATH = %2 >> CONFIGS\openssl_local
echo ORGNAME = %orgname% >> CONFIGS\openssl_local
echo ORGUNITNAME = OCSP Signing Certificate >> CONFIGS\openssl_local
echo COMMONNAMESTRING = Common Name (CN=server.domain.com) >> CONFIGS\openssl_local
echo COMMONNAME = %1 >> CONFIGS\openssl_local
echo CERTPOLICY = %certPolicy% >> CONFIGS\openssl_local
type CONFIGS\openssl.OCSP.cnf >> CONFIGS\openssl_local

if "%3" equ "" echo "Setting hashing algorithm to SHA1" && set SHA="sha1"
if "%3" equ "sha1" echo "Setting hashing algorithm to SHA1" && set SHA="sha1"
if "%3" equ "sha256" echo "Setting hashing algorithm to SHA256" && set SHA="sha256"
if "%SHA%" equ "" echo Usage:  make.ocspsign.cmd ^<certificate name^> ^<CA Cert Name^> [[sha1 or sha256] [rsa1024 or rsa2048 or rsa4096]] && goto end

if "%4" equ "" echo "Setting encryption algorithm to RSA2048" && set RSA="2048"
if "%4" equ "rsa1024" echo "Setting encryption algorithm to RSA1024" && set RSA="1024"
if "%4" equ "rsa2048" echo "Setting encryption algorithm to RSA2048" && set RSA="2048"
if "%4" equ "rsa4096" echo "Setting encryption algorithm to RSA4096" && set RSA="4096"
if "%RSA%" equ "" echo Usage:  make.ocspsign.cmd ^<certificate name^> ^<CA Cert Name^> [[sha1 or sha256] [rsa2048 or rsa1024 or rsa406]] && goto end

openssl genrsa -out SERVERCERTS\%2\%1.key %RSA%
openssl req -new -config CONFIGS\openssl_local -days 1024 -key SERVERCERTS\%2\%1.key -out SERVERCERTS\%2\%1.csr
openssl x509 -req -%SHA% -days 1024 -CA CA\%2.cer -CAkey CA\%2.key -in SERVERCERTS\%2\%1.csr -CAserial PROCESS\%2\serial -extfile CONFIGS\openssl_local -extensions v3_ca -out SERVERCERTS\%2\%1.crt

echo y |del SERVERCERTS\%2\*.csr
echo y |del CONFIGS\openssl_local

echo.
echo.
set /P if_pkcs12=Do you want to create a PKCS12 version? y or n:
if "%if_pkcs12%" equ "y" openssl pkcs12 -export -in SERVERCERTS\%2\%1.crt -inkey SERVERCERTS\%2\%1.key -out SERVERCERTS\%2\%1.p12

echo.
echo.
echo Complete.
if "%if_pkcs12%" equ "y" echo %1.crt, %1.key, and %1.p12 have been created and are in the SERVERCERTS\%2 folder && goto end
echo %1.cer and %1.key have been created and are in the SERVERCERTS folder
goto end

:CERTPOLICYBUILD
set certPolicy=%certPolicy%,%1
goto end

:INFO
echo ####### OCSP Signing Certificate Creator #####
echo #
echo # Description: creates an OCSP signing certificate for use with an OCSP responder. Customiization of the OCSP
echo #     signing certificate is provided in the CONFIGS\openssl.OCSP.cnf file in the [ v3_ca ] section.
echo #
echo # Usage:  make.ocspsign.cmd ^<certificate name^> ^<CA Cert Name^> [[sha1 or sha256] [rsa2048 or rsa1024 or rsa4096]] 
echo #
echo #    Ex. make.ocspsign.cmd ocsp1.alpha.com ca.alpha.com
echo #
echo #######
goto end

:end