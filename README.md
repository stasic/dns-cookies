# dns-cookies
Checking DNS ANYCAST instances (BIND) for synchronized DNS Cookies

With BIND 9.11 and newer DNS Cookies are enabled **automatically**. 
Either synchronize them with following config (siphash24 is available since BIND 9.14.5):
```
  cookie-algorithm siphash24;
  cookie-secret "shared-secret-string";
```
Or disable cookies with following config:
```
  answer-cookie no;
```

ISC addressed this issue in their knowledge base:
https://kb.isc.org/docs/dns-cookies-on-servers-in-anycast-clusters

BIND 9.14.10 ARM (Administrator Reference Manual):
https://downloads.isc.org/isc/bind9/9.14.10/doc/arm/Bv9ARM.ch05.html#boolean_options
