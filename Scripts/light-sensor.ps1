 param (
    [string]$ip,
    [string]$port
)

$url = "http://$ip/$port"
$webClient = New-Object System.Net.WebClient
$content = $webClient.DownloadString($url)
Write-Output $content
