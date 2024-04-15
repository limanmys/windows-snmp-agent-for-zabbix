param (
    [string]$community,
    [string]$ipAddress,
    [string]$oid
)

$result = snmpwalk -v2c -c $community $ipAddress $oid
$response = $result -replace '.*STRING:\s*'

Write-Output $response
