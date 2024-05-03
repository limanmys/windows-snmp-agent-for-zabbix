$directoryPath = "C:\Users\deren\Desktop"

# Get all txt files in the directory
$txtFiles = Get-ChildItem -Path $directoryPath -Filter "*.txt"

# Create an array to store IP addresses
$ipAddresses = @()

# Loop through each txt file
foreach ($file in $txtFiles) {
    # Read the contents of the file
    $fileContents = Get-Content $file.FullName

    # Loop through each line in the file
    foreach ($line in $fileContents) {
        if ($line -match "IP_ADDRESS\s*=\s*(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})") {
            # Extract and add the IP address to the array
            $ipAddress = $matches[1]
            $ipAddresses += $ipAddress
            break
        }
    }
}

# Manually create JSON string
$jsonOutput = "["
foreach ($ip in $ipAddresses) {
    $jsonOutput += "{`"IP_Address`": `"$ip`"}, "
}
$jsonOutput = $jsonOutput.TrimEnd(", ") + "]"

# Output the JSON
Write-Output $jsonOutput
