param(
    [string]$disable,
    [string]$enable
)

# Paths
$multiMonitorToolPath = Join-Path $PSScriptRoot "MultiMonitorTool.exe"
$logPath = Join-Path $PSScriptRoot "display-onoff.log"

function Log($message) {
    Write-Output $message
    Add-Content -Path $logPath -Value ("[" + (Get-Date) + "] " + $message)
}

function ExecuteMultiMonitorCommand($action, $monitorId) {
    & $multiMonitorToolPath /$action $monitorId

    if ($?) {
        Log "DEBUG: Successfully executed $action command for monitor $monitorId"
    } else {
        Log "ERROR: Failed to execute $action command for monitor $monitorId"
    }
}

# Debugging: Print Parameters
Log "DEBUG: Disable parameter received: $disable"
Log "DEBUG: Enable parameter received: $enable"

# Enable monitors
if ($enable) {
    $enableMonitors = $enable -split ','
    Log "DEBUG: Enabling monitors: $($enableMonitors -join ', ')"

    $enableMonitors | ForEach-Object {
        ExecuteMultiMonitorCommand "enable" $_
    }
}

# Disable monitors
if ($disable) {
    $disableMonitors = $disable -split ','
    Log "DEBUG: Disabling monitors: $($disableMonitors -join ', ')"

    $disableMonitors | ForEach-Object {
        ExecuteMultiMonitorCommand "disable" $_
    }
}


