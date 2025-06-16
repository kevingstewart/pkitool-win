# PKITOOL (Windows Version)
### OpenSSL scripting environment for the creation and management of PKI certificates and private keys

Creates:
* Certificate Authority roots
* Certificate Authority subordinate roots
* Certificate Revocation Lists
* OCSP Signing Certificates
* Web Server Certificates
* User Certificates
* Cross-signed certificates

Also supports:
* Certificate revocation
* Local OCSP response
* RSA and ECC certificates
* RSA 1024, 2048, 4096, and 8192-bit
* SHA1 and SHA256

-----
### Getting Started

On a Windows machine (command terminal), execute the ```START_OPENSSL.cmd``` script, which will initiate a shell environment in a mapped folder (z:). In the environment, run any of the "make.*" commands to create respective key material. The command will provide usage information.
