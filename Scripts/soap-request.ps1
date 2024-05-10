# usage .\soap-request-sumtwo.ps1 "http://localhost:8000/" 4 5
param(
    [string]$endpoint,
    [double]$num1,
    [double]$num2
)

$requestBody = @"
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:exam="example.soap.server">
   <soapenv:Header/>
   <soapenv:Body>
      <exam:sum_numbers>
         <exam:num1>$num1</exam:num1>
         <exam:num2>$num2</exam:num2>
      </exam:sum_numbers>
   </soapenv:Body>
</soapenv:Envelope>
"@

$request = [System.Net.WebRequest]::Create($endpoint)
$request.ContentType = "text/xml"
$request.Method = "POST"

$requestStream = $request.GetRequestStream()
$requestStream.Write([System.Text.Encoding]::UTF8.GetBytes($requestBody), 0, $requestBody.Length)
$requestStream.Close()

$response = $request.GetResponse()

$reader = New-Object System.IO.StreamReader($response.GetResponseStream())
$responseBody = $reader.ReadToEnd()
$reader.Close()

[xml]$xmlResponse = $responseBody
$result = $xmlResponse.Envelope.Body.sum_numbersResponse.sum_numbersResult

Write-Host "The sum of $num1 and $num2 is: $result"
