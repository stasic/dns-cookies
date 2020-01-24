# dns-cookies
Checking DNS ANYCAST instances (BIND) for synchronized DNS Cookies

With BIND 9.11 and newer DNS Cookies are enabled *automatically*. 
Either synchronize them with following config (siphash24 is available in BIND 9.14.5):
```
  cookie-algorithm siphash24;
  cookie-secret string;
```
Or disable cookies with following config:
```
  answer-cookie no;
```

https://kb.isc.org/docs/dns-cookies-on-servers-in-anycast-clusters
