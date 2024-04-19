param (
    [string]$community,
    [string]$ipAddress,
    [string]$oid
)

$result = snmpwalk -t 1  -r 1 -v2c -c $community $ipAddress $oid 2>$null
$preresponse = $result -replace '.*iso.*=.*:\s*'

$response = if ($preresponse) { $preresponse } else { '-' }
Write-Output $response
