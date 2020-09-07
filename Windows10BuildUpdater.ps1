<#
.SYNOPSIS
    Powershell Script for upgrading Windows 10 quietly to his latest build.
.DESCRIPTION
    Powershell Script is downloading the 'Win10Upgrade' tool and is running it silently to upgrade Windows 10 to the latest build. 
    After the upgrade, the user gets the notification for rebooting his machine.
.NOTES
    Created by: T13nn3s
    Date: 04-09-2020
#>

#Requires -RunAsAdministrator
function Write-Log {
    [CmdletBinding()]
    param (
        [parameter(
            Mandatory = $true,
            HelpMessage = "Specify log messaging.",
            Position = 1
        )][alias("msg")]
        [ValidateNotNullOrEmpty()]
        [string]
        $Message,

        [parameter(
            Mandatory = $true,
            HelpMessage = "Specify log category ('Information', 'Warning' or 'Error'.",
            Position = 2
        )][alias('info')]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('Information', 'Warning', 'Error')]
        [string]
        $Severity
        
    ) # End param
    
    $time = Get-Date -Format "d-M-yyyy HH:mm:ss"
    $LogFile = $PSScriptRoot + "\PSWindowsUpdate.log"

    if (Test-path $LogFile) {
        
    }
    Else {
        New-Item -path $PSScriptRoot -Name "PSWindowsUpate.log"
    }

    Add-content -Path $LogFile -value "$severity $time $message" -Passthru
} # End Write-Log function

# General
$UpdateFolder = "C:\PowershellWindows10BuildUpdater"
$webClient = New-Object System.Net.WebClient
$url = 'https://go.microsoft.com/fwlink/?LinkID=799445'

# Create PowershellWindows10BuildUpdater folder
try {
    New-Item $UpdateFolder -Type Directory
}
Catch {
    $errormessage = $_.exception.message
    Write-Log -Severity Error -Message "Cannot create $($UpdateFolder)... Errormessage: $errormessage"
    Break
}

# Test if the folder is created
if (Test-path $UpdateFolder) {
    Write-Log -Severity Error -Message "$($UpdateFolder) is created."
}
Else {
    Write-Log -Severity Error -Message "$($UpdateFolder)... Is not there" 
}

# Go to the folder
Set-Location $UpdateFolder
$file = "$($UpdateFolder)\Win10Upgrade.exe"

# Download the Win10Upgrade Tool
Try {
    $webClient.DownloadFile($url, $file)

    # Start the upgrade process
    Start-Process -FilePath $file -ArgumentList '/quietinstall /skipeula /auto upgrade /copylogs $UpdateFolder'
}
Catch {
    $errormessage = $_.exception.message
    Write-Log -Severity Error -Message "Update failed... Errormessage: $errormessage"
}



