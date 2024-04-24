
$server = "<your-zabbix-server-ip-address>"

# Check if the server variable has been properly configured.
# If not, prompt the user to edit it before continuing.
if ($server -eq "<your-zabbix-server-ip-address>") {
    Write-Host "Please edit the Zabbix server IP address. The script will not proceed and editing is mandatory."

    # Script execution should halt here or any other necessary action can be taken.
    exit # Terminates the script execution.
}

$zabbixAgentDirectory = "C:\Program Files\zabbix-agent"



$scriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Definition

$zipFile = Join-Path -Path $scriptDirectory -ChildPath "zabbix-agent.zip"

$destination = "C:\Program Files"

if (Test-Path $zipFile) {
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    
    if (-not (Test-Path $destination)) {
        New-Item -ItemType Directory -Path $destination -Force | Out-Null
    }
    
    [System.IO.Compression.ZipFile]::ExtractToDirectory($zipFile, $destination)
    
    Write-Host "Extraction completed."
} else {
    Write-Host "Zip file not found: $zipFile"
}


Start-Process -FilePath "$zabbixAgentDirectory\vc_redist.x64.exe" -ArgumentList "/quiet", "/norestart" -Wait

(Get-Content -Path "$zabbixAgentDirectory\conf\zabbix_agentd.conf") | ForEach-Object {$_ -Replace '<your-ip>', "$server"} | Set-Content -Path "$zabbixAgentDirectory\conf\zabbix_agentd.conf"

& "$zabbixAgentDirectory\bin\zabbix_agentd.exe" --config "$zabbixAgentDirectory\conf\zabbix_agentd.conf" --install
New-NetFirewallRule -DisplayName "Zabbix Agent Rule" -Direction Inbound -LocalPort 10050 -Protocol TCP -Action Allow

$currentPath = [Environment]::GetEnvironmentVariable("Path", "Machine")

$snmpwalkDirectory = "$zabbixAgentDirectory"

if (-not (Test-Path -Path $zabbixAgentDirectory)) {
    New-Item -ItemType Directory -Path $zabbixAgentDirectory | Out-Null
}

$snmpwalkFilePath = "$zabbixAgentDirectory\snmpwalk.exe"

if (-not (Test-Path -Path $snmpwalkFilePath)) {
    Invoke-WebRequest -Uri $snmpwalkDownloadUrl -OutFile $snmpwalkFilePath
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Failed find snmpwalk.exe. Exiting."
        exit 1
    }
}

if ($currentPath -notlike "*$snmpwalkDirectory*") {
    [Environment]::SetEnvironmentVariable("Path", "$currentPath;$snmpwalkDirectory", "Machine")

    Write-Host "Directory added to PATH. You can now use 'snmpwalk' command."
} else {
    Write-Host "Directory is already in PATH."
    
}
& "$zabbixAgentDirectory\bin\zabbix_agentd.exe" --start --config "$zabbixAgentDirectory\conf\zabbix_agentd.conf"

