@echo off

rem ===================================================
rem Author: k.stewart@f5.com
rem ===================================================

set processpath=
set orgunitname=
set orgname=
set commonnamestring=
set commonname=
set email=
set upn=
set SHA=
set RSA=

if "%1" equ "" goto INFO
if "%2" equ "" goto INFO
if "%3" equ "" goto INFO

if NOT EXIST CA\%2.cer echo CA %2 does not exist. && goto end
if NOT EXIST CA\%2.key echo CA %2 does not exist. && goto end

if NOT EXIST USERCERTS\%2 mkdir USERCERTS\%2
if NOT EXIST PROCESS\%2\index.txt echo 2>PROCESS\%2\index.txt >nul
if NOT EXIST PROCESS\%2\index.txt.attr echo 2>PROCESS\%2\index.txt.attr >nul
if NOT EXIST PROCESS\%2\serial echo 01>PROCESS\%2\serial
if not exist PROCESS\%2\%2.srl echo 2>PROCESS\%2\%2.srl >nul

for /f "tokens=1,2,3,4,5* delims=O=," %%i in ('openssl x509 -in CA\%2.cer -text ^|find "O=" ^|find "Subject"') do set orgname=%%l
for /f "tokens=1* delims=@" %%i in ('echo %3') do set edipi=%%i

if exist CONFIGS\openssl_local echo Y |del CONFIGS\openssl_local
echo PROCESSPATH = %2 >> CONFIGS\openssl_local
echo ORGNAME = %orgname% >> CONFIGS\openssl_local
echo ORGUNITNAME = User Certificate >> CONFIGS\openssl_local
echo COMMONNAMESTRING = Common Name (CN=subject.name.edipi) >> CONFIGS\openssl_local
echo COMMONNAME = %1.%edipi% >> CONFIGS\openssl_local
echo EMAIL = %1@%orgname% >> CONFIGS\openssl_local
echo UPN = %3 >> CONFIGS\openssl_local
type CONFIGS\openssl.USER.cnf >> CONFIGS\openssl_local

if "%4" equ "" echo "Setting hashing algorithm to SHA1" && set SHA="sha1"
if "%4" equ "sha1" echo "Setting hashing algorithm to SHA1" && set SHA="sha1"
if "%4" equ "sha256" echo "Setting hashing algorithm to SHA256" && set SHA="sha256"
if "%SHA%" equ "" echo Usage:  make.user.cmd ^<certificate name^> ^<CA Cert Name^> ^<UserPrincipalName@suffix^> [[sha1 or sha256] [rsa2048 or rsa1024 or rsa4096]] && goto end

if "%5" equ "" echo "Setting encryption algorithm to rsa2048" && set RSA="2048"
if "%5" equ "rsa1024" echo "Setting encryption algorithm to RSA1024" && set RSA="1024"
if "%5" equ "rsa2048" echo "Setting encryption algorithm to RSA2048" && set RSA="2048"
if "%5" equ "rsa4096" echo "Setting encryption algorithm to RSA4096" && set RSA="4096"
if "%RSA%" equ "" echo Usage:  make.user.cmd ^<certificate name^> ^<CA Cert Name^> ^<UserPrincipalName@suffix^> [[sha1 or sha256] [rsa2048 or rsa1024 or rsa4096]] && goto end

openssl genrsa -out USERCERTS\%2\%1.key %RSA%
openssl req -new -days 1024 -key USERCERTS\%2\%1.key -out USERCERTS\%2\%1.csr -config CONFIGS\openssl_local 
openssl x509 -req -%SHA% -days 1024 -CA CA\%2.cer -CAkey CA\%2.key -in USERCERTS\%2\%1.csr -CAserial PROCESS\%2\serial -extfile CONFIGS\openssl_local -extensions usr_cert -out USERCERTS\%2\%1.crt

echo y |del USERCERTS\%2\*.csr
echo y |del CONFIGS\openssl_local

echo.
echo.
  set /P if_pkcs12=Do you want to create a PKCS12 version? y or n:
  if "%if_pkcs12%" equ "y" openssl pkcs12 -export -in USERCERTS\%2\%1.crt -inkey USERCERTS\%2\%1.key -out USERCERTS\%2\%1.p12

echo.
echo.
echo Complete.
if "%if_pkcs12%" equ "y" echo %1.crt, %1.key, and %1.p12 have been created and are in the USERCERTS\%2 folder && goto end
echo %1.cer and %1.key have been created and are in the USERCERTS\%2 folder
goto end

:INFO
echo ####### Smartcard User Certificate Creator #####
echo #
echo # Description: creates a smartcard user certificate. Customization of the user certificate is provided
echo #     in the CONFIGS\openssl.USER.cnf file in the [ usr_cert ] section.
echo #
echo # Usage:  make.user.cmd ^<certificate name^> ^<CA Cert Name^> ^<UserPrincipalName@suffix^> [[sha1 or sha256] [rsa2048 or rsa1024 or rsa4096]] 
echo #
echo #   Ex. make.user.cmd joe.user ca.alpha.com 1234567890@alpha.com
echo #
echo #######
goto end

:end