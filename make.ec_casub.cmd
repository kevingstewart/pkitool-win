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
rem if NOT EXIST EC_CA\%2.cer echo CA %2 does not exist. && goto end
rem if NOT EXIST EC_CA\%2.key echo CA %2 does not exist. && goto end

if NOT EXIST PROCESS\%1 mkdir PROCESS\%1

if NOT EXIST PROCESS\%1\index.txt echo 2>PROCESS\%1\index.txt >nul
if NOT EXIST PROCESS\%1\serial echo 01>PROCESS\%1\serial

for /f "tokens=1,2,3,4,5* delims=O=," %%i in ('openssl x509 -in EC_CA\%2.cer -text ^|find "O=" ^|find "Subject"') do set orgname=%%l

if exist CONFIGS\openssl_local echo Y |del CONFIGS\openssl_local
echo PROCESSPATH = %1 >> CONFIGS\openssl_local
echo ORGNAME = %orgname% >> CONFIGS\openssl_local
echo ORGUNITNAME = Subordinate Authority >> CONFIGS\openssl_local
echo COMMONNAMESTRING = Common Name (CN=server.domain.com) >> CONFIGS\openssl_local
echo COMMONNAME = %1 >> CONFIGS\openssl_local
type CONFIGS\openssl.CASUB.cnf >> CONFIGS\openssl_local

if "%3" equ "" echo "Setting EC algorithm to prime256v1" && set EC_ALG="prime256v1"
if "%3" equ "prime256v1" echo "Setting EC algorithm to prime256v1" && set EC_ALG="prime256v1"
if "%3" equ "secp384r1" echo "Setting EC algorithm to secp384r1" && set EC_ALG="secp384r1"
if "%3" equ "secp521r1" echo "Setting EC algorithm to secp521r1" && set EC_ALG="secp521r1"
if "%EC_ALG%" equ "" echo Usage:  make.ec_casub.cmd ^<certificate fqdn^> ^<CA Cert Name^> [[prime256v1 or secp384r1 or secp521r1] [sha256 or sha384]] && goto end

if "%4" equ "" echo "Setting hash algorithm to SHA256" && set HASH="-SHA256"
if "%4" equ "sha256" echo "Setting hash algorithm to SHA256" && set HASH="-SHA256"
if "%4" equ "sha384" echo "Setting hash algorithm to SHA384" && set HASH="-SHA384"
if "%HASH%" equ "" echo Usage:  make.ec_casub.cmd ^<certificate fqdn^> ^<CA Cert Name^> [[prime256v1 or secp384r1 or secp521r1] [sha256 or sha384]] && goto end

openssl ecparam -name %EC_ALG% -genkey -out EC_CA\%1.key
openssl req -new -config CONFIGS\openssl_local -days 4096 -key EC_CA\%1.key -out EC_CA\%1.csr
openssl x509 -req %HASH% -days 4096 -CA EC_CA\%2.cer -CAkey EC_CA\%2.key -in EC_CA\%1.csr -CAserial PROCESS\%1\serial -extfile CONFIGS\openssl_local -extensions v3_ca -out EC_CA\%1.cer

echo y |del EC_CA\*.csr
echo y |del CONFIGS\openssl_local

echo.
echo.
echo Complete.
echo %1.cer and %1.key have been created and are in the EC_CA folder
goto end

:INFO
echo ####### Subordinate EC CA Certificate Creator #####
echo #
echo # Description: creates subordinate EC CA certificates. Customization of the subordinate certificate is
echo #     provided in the CONFIGS\openssl.CASUB.cnf file in the [ v3_ca ] section.
echo #
echo # Usage:  make.ec_casub.cmd ^<certificate fqdn^> ^<CA Cert Name^> [[prime256v1 or secp384r1 or secp521r1] [sha256 or sha384]]
echo #
echo #   Ex. make.ec_casub.cmd sub-ca1.alpha.com ca.alpha.com
echo #
echo #######
goto end

:end