param (
    [Parameter(Mandatory=$true)]
    [string]$username,

    [Parameter(Mandatory=$true)]
    [string]$authPassword,

    [Parameter(Mandatory=$true)]
    [ValidateSet("MD5", "SHA")]
    [string]$authProtocol,

    [Parameter(Mandatory=$true)]
    [string]$privPassword,

    [Parameter(Mandatory=$true)]
    [ValidateSet("DES", "AES")]
    [string]$privProtocol,

    [Parameter(Mandatory=$true)]
    [string]$ipAddress,

    [Parameter(Mandatory=$true)]
    [string]$oid
)

$result = snmpwalk -v3 -l authPriv -u $username -a $authProtocol -A $authPassword -x $privProtocol -X $privPassword $ipAddress $oid
$response = $result -replace '.*STRING:\s*'

Write-Output $response
