@echo off

rem ===================================================
rem Author: kevin-at-f5-dot-com
rem ===================================================

set processpath=
set orgunitname=
set commonnamestring=
set commonname=
set EC_ALG=
set HASH=

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

if "%2" equ "" echo "Setting EC algorithm to prime256v1" && set EC_ALG="prime256v1"
if "%2" equ "prime256v1" echo "Setting EC algorithm to prime256v1" && set EC_ALG="prime256v1"
if "%2" equ "secp384r1" echo "Setting EC algorithm to secp384r1" && set EC_ALG="secp384r1"
if "%2" equ "secp521r1" echo "Setting EC algorithm to secp521r1" && set EC_ALG="secp521r1"
if "%EC_ALG%" equ "" echo Usage:  make.caroot.cmd ^<certificate fully qualified name^> [[prime256v1 or secp384r1 or secp521r1] [sha256 or sha384]] && goto end

if "%3" equ "" echo "Setting hash algorithm to SHA256" && set HASH="-SHA256"
if "%3" equ "sha256" echo "Setting hash algorithm to SHA256" && set HASH="-SHA256"
if "%3" equ "sha384" echo "Setting hash algorithm to SHA384" && set HASH="-SHA384"
if "%HASH%" equ "" echo Usage:  make.ec_caroot.cmd ^<certificate fully qualified name^> [[prime256v1 or secp384r1 or secp521r1] [sha256 or sha384]] && goto end

openssl ecparam -name %EC_ALG% -genkey -out EC_CA\%1.key
openssl req -config CONFIGS\openssl_local -key EC_CA\%1.key -new -x509 -days 4096 %HASH% -out EC_CA\%1.cer

echo y |del CONFIGS\openssl_local

echo.
echo.
echo Complete.
echo %1.cer and %1.key have been created and are in the EC_CA folder
goto end

:INFO
echo ####### Self-Signed EC Root CA Certificate Creator #####
echo #
echo # Description: creates a self-signed EC root CA certificate. Customization of the CA certificate is provided
echo #     in the CONFIGS\openssl.CAROOT.cnf file in the [ v3_ca ] section.
echo #
echo # Usage:  make.ec_caroot.cmd ^<certificate fully qualified name^> [[prime256v1 or secp384r1 or secp521r1] [sha256 or sha384]]
echo #
echo #    Ex. make.ec_caroot.cmd ca.alpha.com
echo #
echo #######
goto end

:end
