$currentPath = [Environment]::GetEnvironmentVariable("Path", "Machine")

$zabbixAgentDirectory = "C:\Program Files\zabbix-agent"
$snmpwalkDirectory = "$zabbixAgentDirectory"

if (-not (Test-Path -Path $zabbixAgentDirectory)) {
    New-Item -ItemType Directory -Path $zabbixAgentDirectory | Out-Null
}

$snmpwalkDownloadUrl = "https://github.com/limanmys/zabbix-agent-slient/releases/download/snmp/snmpwalk.exe"
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
