### powerwcf

A simple powershell module for talking to WCF services from powershell. 
You might think of it as a poor mans "new-webserviceproxy" that also works on powershell core / cross platform..

**WARNING! THIS IS JUST A POC AND SHOULD NOT BE USED IN PRODUCTION!**

#### Example use in a powershell console:

```
 > install-package powerwcf
 > $proxy = New-PowerWcfProxy -uri http://test.local/myservice.svc
 > $proxy.myserviceclient.someMethod("test").Result
```
