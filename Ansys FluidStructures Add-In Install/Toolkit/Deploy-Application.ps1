<#
.SYNOPSIS

ANSYS 2024 R2 Fluid and Structures Add-In Installation

.DESCRIPTION

This file is the installation and uninstallation file for ANSYS 2024 R2 Fluid and Structures Add-In for ANSYS Workbench using PSADT

.NOTES

ANSYS License Server - <*LICENSE SERVER HERE*>
Default Ports - 2325,1055 <*DEFAULT ANSYS PORTS*>

## QUICK NOTE ABOUT THE PORTS ##

1055 is the default ANSYS FLEXNet port

2325 is the default ANSYS Licensing Interconnect port

When doing a normal install for ANSYS, only the 1055 port is required

But when running the 'setup.exe' from powershell and putting the license server info as part of a parameter
then the other port is also required

Here is the normal ANSYS powershell command:

** Make sure you are in the directory of the 'setup.exe' **

'setup.exe -silent -install_dir "<*INSTALL PATH HERE*>" -licserverinfo 2325:1055:<*LICENSE SERVER HERE*>'

** Can also use a license file as well **

'setup.exe -silent -install_dir "<*INSTALL PATH HERE*>" -licfilepath "path_to/license_file.lic"' 

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
    [String]$appName = 'ANSYS FluidStructures Add-In'
    [String]$appVersion = '2024 R2'
    [String]$appArch = 'x64'
    [String]$appLang = 'EN'
    [String]$appRevision = '01'
    [String]$appScriptVersion = '1.0.0'
    [String]$appScriptDate = '11/14/2024'
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
        
        [String]$installPhase = 'Installation'

        Execute-Process -Path "$dirFiles\FLUIDSTRUCTURES_2024R2_WINX64\setup.exe" `
        -Parameters "-silent -install_dir `"<*INSTALL PATH HERE*>`" -licserverinfo `"2325:1055:<*LICENSE SERVER HERE*>`"" `
        -WindowStyle Hidden `
        -Passthru
        
        [String]$installPhase = 'Post-Installation'

        
    }
    ElseIf ($deploymentType -ieq 'Uninstall') {
       
        [String]$installPhase = 'Pre-Uninstallation'

        [String]$installPhase = 'Uninstallation'

        [String]$installPhase = 'Post-Uninstallation'


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
