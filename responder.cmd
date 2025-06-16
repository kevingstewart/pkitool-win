rem ===================================================
rem Author: k.stewart@f5.com
rem ===================================================

openssl ocsp -index PROCESS\subca1.f5demolab.com\index.txt -port 8888 -CA CA\subca1.f5demolab.com.cer -rsigner SERVERCERTS\subca1.f5demolab.com\ocsp.f5demolab.com.crt -rkey SERVERCERTS\subca1.f5demolab.com\ocsp.f5demolab.com.key -text -out responder.log.txt