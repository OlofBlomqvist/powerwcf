### powerwcf

A simple powershell module for talking to WCF services from powershell core (cross platform).

**WARNING! THIS IS JUST A POC AND SHOULD NOT BE USED IN PRODUCTION!**

#### Example use in a powershell console:

```
 > install-package powerwcf
 > $proxy = New-PowerWcfProxy -uri http://test.local/myservice.svc
 > $proxy.myserviceclient.someMethod("test").Result
```

#### How it works:
 
 The script will install dotnet-svcutil and use that to generate a c# reference.cs file
 which is then compiled and its types imported to powershell. New-PowerWcfProxy will
 create a wrapper object containing instances of all service clients available.


