 param (
    [string]$ipAddress,
    [string]$stateAddress
)

Invoke-RestMethod http://$ipAddress/$stateAddress -TimeoutSec 3