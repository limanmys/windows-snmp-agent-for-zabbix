$ipAddress = $args[0]

$pingResult = Test-Connection -ComputerName $ipAddress -Count 1 -Quiet

# Ping sonucuna göre durumu belirle
if ($pingResult) {
    Write-Output "UP"
} else {
    Write-Output "DOWN"
}
