Function Assert-WCFDeps {
[cmdletbinding()]
param()
    
    # Look for dotnet-svcutil and install if missing - throw on error.
    $data = dotnet tool list --global| select-string dotnet-svcutil
    if($? -and $data) {
        Write-Verbose "Found powershell global tool 'dotnet-svcutil'."
    } else {
        Write-Verbose "Installing dotnet-svcutil.."
        dotnet tool install --global dotnet-svcutil
        if(-not $?) {
            throw "Failed to install dotnet-svcutil."
        }
    }
}

<#
.SYNOPSIS 
 Like get-webserviceproxy but for powershell core
.EXAMPLE
 $proxy = New-PowerWcfProxy -uri http://test.local/myservice.svc?singleWsdl
 $proxy.MyServiceClient.GetStuffAsync(1,"two").Result
#>
Function New-PowerWcfProxy {
    [cmdletbinding()]
    param([switch]$force,[parameter(mandatory)][string]$uri)
    Assert-WCFDeps
    $tempPath = [System.IO.Path]::GetTempPath()
    $md5 = New-Object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider
    $utf8 = New-Object -TypeName System.Text.UTF8Encoding
    $hash = [System.BitConverter]::ToString($md5.ComputeHash($utf8.GetBytes($uri))) -replace "-",""
    $filename = "$($hash).cs"
    $tempFilePath = Join-Path -Path $tempPath -ChildPath $filename

    if($force -and (test-path $tempFilePath)) {
        Remove-Item $tempFilePath -Force -Confirm:$false -ErrorAction Stop
    }

    if(test-path $tempFilePath) {
        write-host -ForegroundColor green "Reference source for this uri already exists, re-using it. You can use the -force flag to re-generate it."
    } else {
        $typename = "*,WCFPROXYTYPE.X$([System.Guid]::NewGuid().ToString())"  -replace "-",""
        Write-Verbose "Invoking command: 'dotnet-svcutil $uri --noStdLib -d $tempPath -o $filename` -n `"$typename`"'"
        
        $x = dotnet-svcutil "$uri" --noStdLib -d $tempPath -o $filename -n "$typename" | Out-String
        if($? -eq $false) {write-error $x;throw "failed to generate reference"}
    }

    $data = (Get-Content -raw $tempFilePath)

    $svcmodnamespace = "System.ServiceModel"
    if($PSVersionTable.PSVersion.Major -gt 5) {
        $svcmodnamespace = "System.Private.ServiceModel"
    }

    $t = add-type -TypeDefinition $data -ReferencedAssemblies @(
        "System.Runtime.Serialization",
        "System.ServiceModel.Primitives",
        "System.Runtime.Serialization.Primitives",
        $svcmodnamespace,
        "netstandard",
        "System.Xml",
        "System.Runtime.Serialization.Xml",
        "System.Collections"
    ) -PassThru -ErrorAction Stop
    
    $proxyObject = New-Object -TypeName "PSCustomObject"

    $binding = [System.ServiceModel.BasicHttpBinding]::new()
    $binding.MaxReceivedMessageSize = 999999
    $t | Where-Object name -ilike "*Client" | ForEach-Object {
        $serviceClientInstance = [scriptblock]::Create("[$($_.fullname)]::new(`$binding,`$uri)").Invoke()[0]
        $defaultDisplaySet = $serviceClientInstance|Get-Member -MemberType method | Select-Object -ExpandProperty Name
        $defaultDisplayPropertySet = New-Object System.Management.Automation.PSPropertySet("DefaultDisplayPropertySet",[string[]]$defaultDisplaySet)
        $PSStandardMembers = [System.Management.Automation.PSMemberInfo[]]@($defaultDisplayPropertySet)
        $serviceClientInstance | Add-Member MemberSet PSStandardMembers $PSStandardMembers -Force
        $proxyObject | add-member -NotePropertyName $_.name -NotePropertyValue $serviceClientInstance
    }
    $proxyObject
}

Export-ModuleMember New-PowerWcfProxy
