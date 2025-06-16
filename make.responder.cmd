@echo off

rem ===================================================
rem Author: kevin-at-f5-dot-com
rem ===================================================

if "%1" equ "" goto INFO
if "%2" equ "" goto INFO
if "%3" equ "" goto INFO

if NOT EXIST CA\%1.cer echo CA %1 certificate does not exist. && goto end
if NOT EXIST CA\%1.key echo CA %1 key does not exist. && goto end
if NOT EXIST SERVERCERTS\%1\%2.crt echo Signing certificate %2 does not exist. && goto end
if NOT EXIST SERVERCERTS\%1\%2.key echo Signing key %2 does not exist. && goto end
if NOT EXIST PROCESS\%1\index.txt echo Revocation database (PROCESS\%1\index.txt) does not exist. && goto end

openssl ocsp -index PROCESS\%1\index.txt -CA CA\%1.cer -rsigner SERVERCERTS\%1\%2.crt -rkey SERVERCERTS\%1\%2.key -port %3
goto end

:INFO
echo ####### OpenSSL OCSP Server #####
echo #
echo # Description: provides a simple OpenSSL OCSP server.
echo #
echo # Usage:  make.responder.cmd ^<CA Cert full name^> ^<Signing Certificate^> ^<Port number^> 
echo #
echo #   Ex. make.responder.cmd crl.alpha.com ocsp1.alpha.com 8888
echo #
echo #######
goto end

:end
