$server = "<your-zabbix-server-ip-address>"

#Download address definitions
$version = "https://cdn.zabbix.com/zabbix/binaries/stable/6.0/6.0.28/zabbix_agent-6.0.28-windows-amd64-openssl.zip"
$vRedistInstallerUrl = "https://aka.ms/vs/16/release/vc_redist.x64.exe"

#Script path definitions
$ping = "https://raw.githubusercontent.com/limanmys/zabbix-agent-slient/main/Scripts/ping-request.ps1"
$snmpv2 = "https://raw.githubusercontent.com/limanmys/zabbix-agent-slient/main/Scripts/snmpv2-request.ps1"
$snmpv3 = "https://raw.githubusercontent.com/limanmys/zabbix-agent-slient/main/Scripts/snmpv3-request.ps1"

# Create directory for scripts
New-Item -Path "C:\Program Files\zabbix-agent\Scripts" -ItemType Directory -Force

# vc_redist.x64 installation
Invoke-WebRequest -Uri $vRedistInstallerUrl -OutFile "C:\Program Files\zabbix-agent\vc_redist.x64.exe"
Start-Process -FilePath "C:\Program Files\zabbix-agent\vc_redist.x64.exe" -ArgumentList "/quiet", "/norestart" -Wait

# Zabbix Agent installation
Invoke-WebRequest -Uri $version -OutFile "C:\Program Files\zabbix-agent\zabbix.zip"
Expand-Archive -Path "C:\Program Files\zabbix-agent\zabbix.zip" -DestinationPath "C:\Program Files\zabbix-agent"

Add-Type -AssemblyName System.IO.Compression.FileSystem
function Unzip
{
    param([string]$zipfile, [string]$outpath)

    [System.IO.Compression.ZipFile]::ExtractToDirectory($zipfile, $outpath)
}

Unzip "C:\Program Files\zabbix-agent\zabbix.zip" "C:\Program Files\zabbix-agent"


# Download scripts
Invoke-WebRequest -Uri $ping -OutFile "C:\Program Files\zabbix-agent\Scripts\ping-request.ps1"
Invoke-WebRequest -Uri $snmpv2 -OutFile "C:\Program Files\zabbix-agent\Scripts\snmpv2-request.ps1"
Invoke-WebRequest -Uri $snmpv3 -OutFile "C:\Program Files\zabbix-agent\Scripts\snmpv3-request.ps1"


# Update zabbix_agentd.conf
(Get-Content -Path "c:\Program Files\zabbix-agent\conf\zabbix_agentd.conf") | ForEach-Object {$_ -Replace '127.0.0.1', "$server"} | Set-Content -Path "c:\Program Files\zabbix-agent\conf\zabbix_agentd.conf"

    
$linesToAdd = @"
UserParameter=deren.ping[*],powershell.exe -File "C:\Program Files\zabbix-agent\Scripts\ping-request.ps1" $1
UserParameter=deren.snmp[*],powershell.exe -File "C:\Program Files\zabbix-agent\Scripts\snmpv2-request.ps1" $1 $2 $3
UserParameter=deren.snmpv3[*],powershell.exe -File "C:\Program Files\zabbix-agent\Scripts\snmpv3-request.ps1" $1 $2 $3 $4 $5 $6 $7

EnableRemoteCommands=1
"@

Add-Content -Path "C:\Program Files\zabbix-agent\conf\zabbix_agentd.conf" -Value $linesToAdd

# Install and start Zabbix Agent
& "C:\Program Files\zabbix-agent\bin\zabbix_agentd.exe" --config "c:\Program Files\zabbix-agent\conf\zabbix_agentd.conf" --install
New-NetFirewallRule -DisplayName "Zabbix Agent Rule" -Direction Inbound -LocalPort 10050 -Protocol TCP -Action Allow

& "C:\Program Files\zabbix-agent\bin\zabbix_agentd.exe" --start --config "C:\Program Files\zabbix-agent\conf\zabbix_agentd.conf"
