@echo off

rem ===================================================
rem Author: k.stewart@f5.com
rem ===================================================

mode con cols=140 lines=60

set OCSPSHELL=1

set currdir=%~dp0
echo Mapping Z: to %currdir%
set OPENSSL_CONF=%currdir%\CONFIGS\openssl.BASE.cnf
set currdir=%currdir:~0,-1%

subst z: "%currdir%"
z:
set PATH=%PATH%;z:\bin
echo.
echo OpenSSL Shell Environment -- Type EXIT to end
echo.
echo To make a self-signed root CA certificate:	make.caroot.cmd
echo To make a subordinate CA certificate:		make.casub.cmd
echo To make a web server certificate:		make.webserver.cmd
echo To make an OCSP signing certificate:		make.ocspsign.cmd
echo To make a smartcard user certificate:		make.user.cmd
echo To revoke a user certificate:			make.revoke.user.cmd
echo To create a new certificate revocation list:	make.crl.cmd
echo To start a simple OpenSSL OCSP responder:	make.responder.cmd
echo To cross-certify a CA certificate:		make.crosscert.cmd

echo.
cmd /T:1E /K TITLE=OPENSSL

:exit
subst z: /D 

