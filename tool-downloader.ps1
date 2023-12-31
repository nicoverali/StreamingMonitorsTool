# Exit if 'MultiMonitorTool.exe' exists in the script's directory
if (Test-Path -Path "$PSScriptRoot\MultiMonitorTool.exe") {
    Write-Host "MultiMonitorTool already installed."
    exit 0
}

# Print message to user
$message = "To use this plugin you need to have MultiMonitorTool installed, would you like to install it ?"
$yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", "Install MultiMonitorTool."
$no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", "Do not install MultiMonitorTool."

$options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)
$result = $host.ui.PromptForChoice($null, $message, $options, 0)

switch ($result) {
    0 {
        # User chose 'Yes', download the tool
        $url = "https://www.nirsoft.net/utils/multimonitortool-x64.zip"
        $output = "$PSScriptRoot\multimonitortool-x64.zip"
        Invoke-WebRequest -Uri $url -OutFile $output

        # Extract the tool and move the exe file to the current directory
        Add-Type -AssemblyName System.IO.Compression.FileSystem
        [System.IO.Compression.ZipFile]::ExtractToDirectory($output, "$PSScriptRoot\multimonitortool_temp")
        Move-Item "$PSScriptRoot\multimonitortool_temp\MultiMonitorTool.exe" "$PSScriptRoot\MultiMonitorTool.exe"

        # Clean up, remove the zip file and temporary directory
        Remove-Item -Path $output
        Remove-Item -Path "$PSScriptRoot\multimonitortool_temp" -Recurse
    }
    1 {
        # User chose 'No', show a message and then exit with error code 1
        Write-Host "The plugin has not been installed because MultiMonitorTool was not installed."
        Start-Sleep -Seconds 3
        exit 1
    }
}
