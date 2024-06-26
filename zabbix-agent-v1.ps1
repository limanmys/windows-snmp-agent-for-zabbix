$server = "192.168.122.192"

#Specify version here
$version = "https://cdn.zabbix.com/zabbix/binaries/stable/6.0/6.0.28/zabbix_agent-6.0.28-windows-amd64-openssl.zip"
New-Item -Path "C:\zabbix-agent" -ItemType Directory


Invoke-WebRequest "$version" -outfile c:\zabbix-agent\zabbix.zip

Add-Type -AssemblyName System.IO.Compression.FileSystem
function Unzip
{
    param([string]$zipfile, [string]$outpath)

    [System.IO.Compression.ZipFile]::ExtractToDirectory($zipfile, $outpath)
}

Unzip "c:\Zabbix-agent\zabbix.zip" "c:\zabbix-agent" 

(Get-Content -Path c:\zabbix-agent\conf\zabbix_agentd.conf) | ForEach-Object {$_ -Replace '127.0.0.1', "$server"} | Set-Content -Path c:\zabbix-agent\conf\zabbix_agentd.conf

C:\zabbix-agent\bin\zabbix_agentd.exe --config c:\zabbix-agent\conf\zabbix_agentd.conf --install


c:\zabbix-agent\bin\zabbix_agentd.exe --start --config C:\zabbix-agent\conf\zabbix_agentd.conf
