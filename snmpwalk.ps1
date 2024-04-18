
$currentPath = [Environment]::GetEnvironmentVariable("Path", "Machine")

$snmpwalkDirectory = "C:\Program Files\"

if ($currentPath -notlike "*$snmpwalkDirectory*") {
    [Environment]::SetEnvironmentVariable("Path", "$currentPath;$snmpwalkDirectory", "Machine")

    Write-Host "Directory added to PATH. You can now use 'snmpwalk' command."
} else {
    Write-Host "Directory is already in PATH."
}
