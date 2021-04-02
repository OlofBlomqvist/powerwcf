### powerwcf

A simple powershell module for talking to WCF services from powershell. 
You might think of it as a poor mans "new-webserviceproxy" that also works on powershell core / cross platform..

**WARNING! THIS IS JUST A POC AND SHOULD NOT BE USED IN PRODUCTION!**

#### Requirements
- dotnet sdk 5+ (https://dotnet.microsoft.com/download)
- powershell 5/6/7 (but probably works on later versions as well)

#### Known Limitations
- Only supports BasicHttpBinding
- No support for authentication
- Service methods returning CultureInfo data (the type changed between .net framework and core)

#### What works
- Tested on Linux (ubuntu 20.04) running powershell 7.
- Tested on Windows 10 running powershell 5.

#### Example use in a powershell console:

```
 > install-package powerwcf
 > $proxy = New-PowerWcfProxy -uri http://test.local/myservice.svc?singleWsdl
 > $proxy.randomsvcClient.someMethod("test").Result
```
