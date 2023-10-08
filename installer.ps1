# installer.ps1

# Dot-source the sunshine-conf.ps1 script to use its functions
. "$PSScriptRoot\sunshine-conf.ps1"

# Define the scripts to be added or removed
$wantedScripts = @(
    @{
        "do" = "powershell $PSScriptRoot\display-onoff.ps1 -disable GSM7714 -enable CLB1234"
        "undo" = "powershell $PSScriptRoot\display-onoff.ps1 -disable CLB1234 -enable GSM7714"
    }
)

function InstallScripts {
    # Get current value of global_prep_cmd
    $currentValue = Get-ConfigArrayValue -key "global_prep_cmd"

    # Convert the hashtables to PSCustomObject
    $wantedObjects = $wantedScripts | ForEach-Object { [PSCustomObject]$_ }
    $currentObjects = $currentValue | ForEach-Object { [PSCustomObject]$_ }

    # New value will start with current objects
    $newValue = [System.Collections.ArrayList]@($currentObjects)

    # Check if each wanted script is in the new value
    foreach ($wantedScript in $wantedObjects) {
        $exists = $newValue | Where-Object {
            $_."do" -eq $wantedScript."do" -and $_."undo" -eq $wantedScript."undo"
        }
        if (-not $exists) {
            $newValue.Add($wantedScript) | Out-Null
        }
    }

    # Update the config file
    Set-ConfigArrayValue -key "global_prep_cmd" -value $newValue
    Write-Host "Scripts installed successfully."
}

function UninstallScripts {
    # Get current value of global_prep_cmd
    $currentValue = Get-ConfigArrayValue -key "global_prep_cmd"

    # Remove the wanted scripts from current value
    $newValue = @()
    foreach ($script in $currentValue) {
        # Check if the script exists in $wantedScripts based on the "do" property
        $existsInWantedScripts = $wantedScripts | Where-Object { $_."do" -eq $script."do" }
        if (-not $existsInWantedScripts) {
            $newValue += $script
        }
    }

    # Update the config file
    if ($newValue.Count -gt 0) {
        Set-ConfigArrayValue -key "global_prep_cmd" -value $newValue
    } else {
        # If there are no scripts left, we can remove the key entirely from the config
        Remove-ConfigKey -key "global_prep_cmd"
    }

    Write-Host "Scripts uninstalled successfully."
}

# Check if the -uninstall switch is provided
if ($args -contains "-uninstall") {
    UninstallScripts
} else {
    InstallScripts
}
