$server = "<your-zabbix-server-ip-address>"

# Check if the server variable has been properly configured.
# If not, prompt the user to edit it before continuing.
if ($server -eq "<your-zabbix-server-ip-address>") {
    Write-Host "Please edit the Zabbix server IP address. The script will not proceed and editing is mandatory."

    # Script execution should halt here or any other necessary action can be taken.
    exit # Terminates the script execution.
}

# Continue with the rest of the code...

#Download address definitions
$version = "https://cdn.zabbix.com/zabbix/binaries/stable/6.0/6.0.28/zabbix_agent-6.0.28-windows-amd64-openssl.zip"
$vRedistInstallerUrl = "https://aka.ms/vs/16/release/vc_redist.x64.exe"
$snmpwalkDownloadUrl = "https://github.com/limanmys/zabbix-agent-slient/releases/download/snmp/snmpwalk.exe"
#Script path definitions
$ping = "https://raw.githubusercontent.com/limanmys/zabbix-agent-slient/main/Scripts/ping-request.ps1"
$snmpv2 = "https://raw.githubusercontent.com/limanmys/zabbix-agent-slient/main/Scripts/snmpv2-request.ps1"
$snmpv3 = "https://raw.githubusercontent.com/limanmys/zabbix-agent-slient/main/Scripts/snmpv3-request.ps1"
$snmpcheck="https://raw.githubusercontent.com/limanmys/zabbix-agent-slient/main/Scripts/snmpcheck.ps1"
$zabbixAgentDirectory = "C:\Program Files\zabbix-agent"

# Create directory for scripts
New-Item -Path "$zabbixAgentDirectory\Scripts" -ItemType Directory -Force
New-Item -Path "$zabbixAgentDirectory\Logs" -ItemType Directory -Force

# vc_redist.x64 installation
Invoke-WebRequest -Uri $vRedistInstallerUrl -OutFile "$zabbixAgentDirectory\vc_redist.x64.exe"
Start-Process -FilePath "$zabbixAgentDirectory\vc_redist.x64.exe" -ArgumentList "/quiet", "/norestart" -Wait

# Zabbix Agent installation
Invoke-WebRequest -Uri $version -OutFile "$zabbixAgentDirectory\zabbix.zip"
Expand-Archive -Path "$zabbixAgentDirectory\zabbix.zip" -DestinationPath "$zabbixAgentDirectory"

Add-Type -AssemblyName System.IO.Compression.FileSystem
function Unzip
{
    param([string]$zipfile, [string]$outpath)

    [System.IO.Compression.ZipFile]::ExtractToDirectory($zipfile, $outpath)
}

Unzip "$zabbixAgentDirectory\zabbix.zip" "$zabbixAgentDirectory"


# Download scripts
Invoke-WebRequest -Uri $ping -OutFile "$zabbixAgentDirectory\Scripts\ping-request.ps1"
Invoke-WebRequest -Uri $snmpv2 -OutFile "$zabbixAgentDirectory\Scripts\snmpv2-request.ps1"
Invoke-WebRequest -Uri $snmpv3 -OutFile "$zabbixAgentDirectory\Scripts\snmpv3-request.ps1"


# Update zabbix_agentd.conf
    
$linesToAdd = @'
LogFile=C:\Program Files\zabbix-agent\Logs\zabbix_agentd.log

LogFile=C:\Program Files\zabbix-agent\Logs\zabbix_agentd.log
LogFileSize=1
DebugLevel=3

Server=<your-ip>

ServerActive=<your-ip>

Hostname=Windows host

RefreshActiveChecks=120
BufferSend=5
BufferSize=100
MaxLinesPerSecond=20

UserParameter=csi.ping[*],powershell.exe -File "C:\Program Files\zabbix-agent\Scripts\ping-request.ps1" $1
UserParameter=csi.snmp[*],powershell.exe -File "C:\Program Files\zabbix-agent\Scripts\snmpv2-request.ps1" $1 $2 $3
UserParameter=csi.snmpcheck[*],powershell.exe -File "C:\Program Files\zabbix-agent\Scripts\snmpcheck.ps1" $1 $2 $3
UserParameter=csi.snmpv3[*],powershell.exe -File "C:\Program Files\zabbix-agent\Scripts\snmpv3-request.ps1" $1 $2 $3 $4 $5 $6 $7
'@

Set-Content -Path "$zabbixAgentDirectory\conf\zabbix_agentd.conf" -Value $linesToAdd
(Get-Content -Path "$zabbixAgentDirectory\conf\zabbix_agentd.conf") | ForEach-Object {$_ -Replace '<your-ip>', "$server"} | Set-Content -Path "$zabbixAgentDirectory\conf\zabbix_agentd.conf"


# Install and start Zabbix Agent
& "$zabbixAgentDirectory\bin\zabbix_agentd.exe" --config "$zabbixAgentDirectory\conf\zabbix_agentd.conf" --install
New-NetFirewallRule -DisplayName "Zabbix Agent Rule" -Direction Inbound -LocalPort 10050 -Protocol TCP -Action Allow

& "$zabbixAgentDirectory\bin\zabbix_agentd.exe" --start --config "$zabbixAgentDirectory\conf\zabbix_agentd.conf"

# Install snmpwalk

$currentPath = [Environment]::GetEnvironmentVariable("Path", "Machine")

$snmpwalkDirectory = "$zabbixAgentDirectory"

if (-not (Test-Path -Path $zabbixAgentDirectory)) {
    New-Item -ItemType Directory -Path $zabbixAgentDirectory | Out-Null
}

$snmpwalkFilePath = "$zabbixAgentDirectory\snmpwalk.exe"

if (-not (Test-Path -Path $snmpwalkFilePath)) {
    Invoke-WebRequest -Uri $snmpwalkDownloadUrl -OutFile $snmpwalkFilePath
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Failed to download snmpwalk.exe. Exiting."
        exit 1
    }
}

if ($currentPath -notlike "*$snmpwalkDirectory*") {
    [Environment]::SetEnvironmentVariable("Path", "$currentPath;$snmpwalkDirectory", "Machine")

    Write-Host "Directory added to PATH. You can now use 'snmpwalk' command."
} else {
    Write-Host "Directory is already in PATH."
}
