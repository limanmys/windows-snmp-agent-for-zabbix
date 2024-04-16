#Definitions

$server = "<your-ip-address>"

#Download address definitions

$version = "https://cdn.zabbix.com/zabbix/binaries/stable/6.0/6.0.28/zabbix_agent-6.0.28-windows-amd64-openssl.zip"
$vRedistInstallerUrl = "https://aka.ms/vs/16/release/vc_redist.x64.exe"

#Script path definitions

$snmpv2 = "https://github.com/limanmys/zabbix-agent-slient/blob/main/Scripts/snmpv2-request.ps1"
$snmpv3 = "https://github.com/limanmys/zabbix-agent-slient/blob/main/Scripts/snmpv3-request.ps1"

New-Item -Path "C:\zabbix-agent" -ItemType Directory

#vc_redist.x64 installation

Invoke-WebRequest -Uri $vRedistInstallerUrl -outfile c:\zabbix-agent\vc_redist.x64.exe
c:\zabbix-agent\vc_redist.x64.exe /quiet /norestart
Remove-Item "c:\zabbix-agent\vc_redist.x64.exe"

#Zabbix Agnet installation

Invoke-WebRequest "$version" -outfile c:\zabbix-agent\zabbix.zip

Add-Type -AssemblyName System.IO.Compression.FileSystem
function Unzip
{
    param([string]$zipfile, [string]$outpath)

    [System.IO.Compression.ZipFile]::ExtractToDirectory($zipfile, $outpath)
}

Unzip "c:\Zabbix-agent\zabbix.zip" "c:\zabbix-agent" 

Invoke-WebRequest -Uri $vRedistInstallerUrl -outfile c:\zabbix-agent\Script\snmpv2-request.ps1
Invoke-WebRequest -Uri $vRedistInstallerUrl -outfile c:\zabbix-agent\Script\snmpv3-request.ps1

(Get-Content -Path c:\zabbix-agent\conf\zabbix_agentd.conf) | ForEach-Object {$_ -Replace '127.0.0.1', "$server"} | Set-Content -Path c:\zabbix-agent\conf\zabbix_agentd.conf

$linesToAdd = @"
UserParameter=deren.ping[*],powershell.exe -File "C:\Program Files\Zabbix Agent\Scripts\snmpv2-request.ps1" $1 $2 $3
UserParameter=deren.snmp[*],powershell.exe -File "C:\Program Files\Zabbix Agent\Scripts\snmpv3-request.ps1" $1 $2 $3 $4 $5 $6 $7
"@

Add-Content -Path "c:\zabbix-agent\conf\zabbix_agentd.conf" -Value $linesToAdd

C:\zabbix-agent\bin\zabbix_agentd.exe --config c:\zabbix-agent\conf\zabbix_agentd.conf --install

New-NetFirewallRule -DisplayName "Zabbix Agent" -Direction Inbound -LocalPort 10050 -Protocol TCP -Action Allow

c:\zabbix-agent\bin\zabbix_agentd.exe --start --config C:\zabbix-agent\conf\zabbix_agentd.conf
