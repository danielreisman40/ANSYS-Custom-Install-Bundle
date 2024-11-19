<#
.SYNOPSIS

ANSYS 2024 R2 Electronics Desktop Installation 

.DESCRIPTION

This file is the installation and uninstallation script for ANSYS 2024 R2 Electronic Desktop for ANSYS Workbench using PSADT
in order to deploy the application over SCCM

This script should:

1. Install the application silently
2. Uninstall the application silently
3. Report progress (and other information) to logs

#>


[CmdletBinding()]
Param (
    [Parameter(Mandatory = $false)]
    [ValidateSet('Install', 'Uninstall', 'Repair')]
    [String]$DeploymentType = 'Install',
    [Parameter(Mandatory = $false)]
    [ValidateSet('Interactive', 'Silent', 'NonInteractive')]
    [String]$DeployMode = 'Interactive',
    [Parameter(Mandatory = $false)]
    [switch]$AllowRebootPassThru = $false,
    [Parameter(Mandatory = $false)]
    [switch]$TerminalServerMode = $false,
    [Parameter(Mandatory = $false)]
    [switch]$DisableLogging = $false
)

Try {
    ## Set the script execution policy for this process
    Try {
        Set-ExecutionPolicy -ExecutionPolicy 'ByPass' -Scope 'Process' -Force -ErrorAction 'Stop'
    } Catch {
    }

    ##*===============================================
    #region VARIABLE DECLARATION
    ##*===============================================
    ## Variables: Application
    [String]$appVendor = 'ANSYS Inc'
    [String]$appName = 'AnsysEM'
    [String]$appVersion = '2024 R2'
    [String]$appArch = 'x64'
    [String]$appLang = 'EN'
    [String]$appRevision = '01'
    [String]$appScriptVersion = '1.0.0'
    [String]$appScriptDate = '11/19/2024'
    [String]$appScriptAuthor = 'Daniel Reisman'
    ##*===============================================
    ## Variables: Install Titles (Only set here to override defaults set by the toolkit)
    [String]$installName = ''
    [String]$installTitle = ''

    ##* Do not modify section below
    #region DoNotModify

    ## Variables: Exit Code
    [Int32]$mainExitCode = 0

    ## Variables: Script
    [String]$deployAppScriptFriendlyName = 'Deploy Application'
    [Version]$deployAppScriptVersion = [Version]'3.10.2'
    [String]$deployAppScriptDate = '08/13/2024'
    [Hashtable]$deployAppScriptParameters = $PsBoundParameters

    ## Variables: Environment
    If (Test-Path -LiteralPath 'variable:HostInvocation') {
        $InvocationInfo = $HostInvocation
    }
    Else {
        $InvocationInfo = $MyInvocation
    }
    [String]$scriptDirectory = Split-Path -Path $InvocationInfo.MyCommand.Definition -Parent

    ## Dot source the required App Deploy Toolkit Functions
    Try {
        [String]$moduleAppDeployToolkitMain = "$scriptDirectory\AppDeployToolkit\AppDeployToolkitMain.ps1"
        If (-not (Test-Path -LiteralPath $moduleAppDeployToolkitMain -PathType 'Leaf')) {
            Throw "Module does not exist at the specified location [$moduleAppDeployToolkitMain]."
        }
        If ($DisableLogging) {
            . $moduleAppDeployToolkitMain -DisableLogging
        }
        Else {
            . $moduleAppDeployToolkitMain
        }
    }
    Catch {
        If ($mainExitCode -eq 0) {
            [Int32]$mainExitCode = 60008
        }
        Write-Error -Message "Module [$moduleAppDeployToolkitMain] failed to load: `n$($_.Exception.Message)`n `n$($_.InvocationInfo.PositionMessage)" -ErrorAction 'Continue'
        ## Exit the script, returning the exit code to SCCM
        If (Test-Path -LiteralPath 'variable:HostInvocation') {
            $script:ExitCode = $mainExitCode; Exit
        }
        Else {
            Exit $mainExitCode
        }
    }

    #endregion
    ##* Do not modify section above
    ##*===============================================
    #endregion END VARIABLE DECLARATION
    ##*===============================================

    If ($deploymentType -ine 'Uninstall' -and $deploymentType -ine 'Repair') {
        
        [String]$installPhase = 'Pre-Installation'

        # Check to see if the Electronics Desktop is running

        Get-Process -Name "Electronics Desktop*"

        Stop-Process -Name "Electronics Desktop*" -Confirm

        [String]$installPhase = 'Installation'

        Execute-Process -Path "$dirFiles\ELECTRONICS_2024R2_WINX64\Electronics_242_winx64\AnsysEM\setup.exe" `
        -Parameters "-silent -licserverinfo `"2325:1055:<*LICENSE SERVER HERE*>`"" `
        -WindowStyle hidden
        -Passthru

        [String]$installPhase = 'Post-Installation'

        # Create a shortcut for AnsysEM Electronics Desktop

        New-Shortcut -Path "<* SHORCUT PATH HERE *>" -TargetPath "<* ELECTRONICS DESKTOP PATH HERE *>" -Description "Electronic Desktop 2024 R2"


    }
    ElseIf ($deploymentType -ieq 'Uninstall') {
       
        [String]$installPhase = 'Pre-Uninstallation'

        
        # Check to see if the Electronics Desktop is running

        Get-Process -Name "Electronics Desktop*"

        Stop-Process -Name "Electronics Desktop*" -Confirm

        [String]$installPhase = 'Uninstallation'

        # Uninstall Electronics Desktop

        Execute-Process -Path "<* PATH TO INSTALLATION *>\AnsysEM\v242\Win64\Uninstall\setup.exe" -Parameters "-silent"

        [String]$installPhase = 'Post-Uninstallation'

        Remove-File -Path "<* SHORCUT PATH HERE *>"

    }
    ElseIf ($deploymentType -ieq 'Repair') {
        
        [String]$installPhase = 'Pre-Repair'

        [String]$installPhase = 'Repair'

        [String]$installPhase = 'Post-Repair'

    }

    ## Call the Exit-Script function to perform final cleanup operations
    Exit-Script -ExitCode $mainExitCode
}
Catch {
    [Int32]$mainExitCode = 60001
    [String]$mainErrorMessage = "$(Resolve-Error)"
    Write-Log -Message $mainErrorMessage -Severity 3 -Source $deployAppScriptFriendlyName
    Show-DialogBox -Text $mainErrorMessage -Icon 'Stop'
    Exit-Script -ExitCode $mainExitCode
}
