# sunshine-conf.ps1

# Define the path to the Sunshine config file
$ConfigPath = "$env:ProgramFiles\Sunshine\config\sunshine.conf"

# Ensure the config file exists
if (-not (Test-Path $ConfigPath)) {
    throw "Sunshine config file not found at $ConfigPath"
}

function Get-ConfigArrayValue {
    param (
        [Parameter(Mandatory=$true)]
        [string]$key
    )

    # Ensure config file exists
    if (-not (Test-Path -Path $ConfigPath)) {
        throw "Sunshine config file not found at $ConfigPath"
    }

    # Extract the value associated with the key
    $pattern = "$key\s*=\s*\[(.*)\]"
    $line = Get-Content -Path $ConfigPath | Where-Object { $_ -match $pattern }
    
    if ($line) {
        $jsonValue = "[ $($matches[1]) ]" # We can still use $matches for this specific operation
        return $jsonValue | ConvertFrom-Json
    }
    
    return @() # Return an empty array if the key does not exist
}

function Set-ConfigArrayValue {
    param (
        [Parameter(Mandatory=$true)]
        [string]$key,

        [Parameter(Mandatory=$true)]
        [array]$value
    )

    

    # Check if the config file exists
    if (-not (Test-Path -Path $ConfigPath)) {
        throw "Sunshine config file not found at $ConfigPath"
    }

    # Read the config file content
    $configContent = Get-Content -Path $ConfigPath

    # Convert the array to a JSON string representation
    $jsonValueArray = $value | ForEach-Object { $_ | ConvertTo-Json -Compress }
    $joinedValue = "[{0}]" -f ($jsonValueArray -join ",")

    # Check if the key already exists in the file
    $matchedLine = $configContent | Where-Object { $_ -match "^$key\s*=" }

    if ($matchedLine) {
        # If it exists, replace its value
        $configContent = $configContent -replace "^$key\s*=.*$", "$key = $joinedValue"
    } else {
        # If not, append the key-value to the end, but ensure it starts on a new line
        $configContent += "`r`n$key = $joinedValue"
    }

    # Write the modified content back to the file
    Set-Content -Path $ConfigPath -Value $configContent
}

function Remove-ConfigKey {
    param (
        [Parameter(Mandatory=$true)]
        [string]$key
    )

    # Check if the config file exists
    if (-not (Test-Path -Path $ConfigPath)) {
        throw "Sunshine config file not found at $ConfigPath"
    }

    # Read the config file content
    $configContent = Get-Content -Path $ConfigPath

    # Remove the key-value pair from the file content
    $configContent = $configContent | Where-Object { $_ -notmatch "^$key\s*=" }

    # Write the modified content back to the file
    Set-Content -Path $ConfigPath -Value $configContent
}