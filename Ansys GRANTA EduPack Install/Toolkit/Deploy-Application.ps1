<#
.SYNOPSIS

ANSYS 2024 R2 Granta EduPack Installation 

.DESCRIPTION

This file is the installation and uninstallation script for ANSYS Granta EduPack v. 2024 R2 
in order to deploy the application over SCCM

This script should:

1. Install the application silently
2. Uninstall the application silently
3. Report progress (and other information) to logs

.NOTES

ANSYS License Server - <*LICENSE SERVER HERE*>
Default Ports - 1055 <*DEFAULT ANSYS PORTS*>

NOTES ABOUT GRANTA EDUPACK SILENT INSTALLATION

1055 is the default ANSYS FLEXNet port

ANSYS Granta EduPack does NOT use the 2325 Licensing Interconnect Port

Install command for the Granta EduPack '.exe' setup file:

** Please ensure you are in the directory of the '.exe' file **

edupack_setup.XXXX_RY.exe /licenseServer:1055@<*LICENSE SERVER HERE*> /install
/quiet

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
    [String]$appName = ' ANSYS Granta EduPack'
    [String]$appVersion = '2024 R2'
    [String]$appArch = 'x64'
    [String]$appLang = 'EN'
    [String]$appRevision = '01'
    [String]$appScriptVersion = '1.0.0'
    [String]$appScriptDate = '11/18/2024'
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

        # Check Granta EduPack if already running
        Get-Process -Name "Granta EduPack*"

        # Check Ansys Workbench if already running
        Get-Process -Name "Ansys Workbench*"

        # Close Granta EduPack if already running
        Stop-Process -Name "Granta EduPack*" -Confirm

        # Close the Ansys Workbench if already running
        Stop-Process -Name "Ansys Workbench*" -Confirm
 
        [String]$installPhase = 'Installation'

        # Install Granta EduPack on Silent Mode
        Execute-Process -Path "$dirFiles\GRANTAEDUPACK_2024R2_WINX64\edupack_setup.2024_R2.exe" `
        -Parameters "/licenseServer:1055@<*LICENSE SERVER HERE*> /install /quiet" `
        -WindowStyle Hidden `
        -Passthru 

        [String]$installPhase = 'Post-Installation'

        # Copy the Granta EduPack shortcut to the public desktop
        Copy-Item -path "<*Granta EduPack Install Path*>\Granta EduPack 2024 R2.lnk" -Destination "<*SHORTCUT PATH HERE*>" 

    }
    ElseIf ($deploymentType -ieq 'Uninstall') {
       
        [String]$installPhase = 'Pre-Uninstallation'

        # Check Granta EduPack if already running
        Get-Process -Name "Granta EduPack*"

        # Check Ansys Workbench if already running
        Get-Process -Name "Ansys Workbench*"

        # Close Granta EduPack if already running
        Stop-Process -Name "Granta EduPack*" -Confirm

        # Close the Ansys Workbench if already running
        Stop-Process -Name "Ansys Workbench*" -Confirm
        
        [String]$installPhase = 'Uninstallation'

        # Find the application in the control panel in "Program and Features"
        $app = Get-WmiObject -Class Win32_Product | Where-Object{$_.Name -eq "Granta EduPack 2024 R2"}

        # Uninstall the app once found
        $app.Uninstall()

        [String]$installPhase = 'Post-Uninstallation'

        # Get rid of the shortcut once app is uninstalled
        Remove-Item -Path "<*SHORTCUT PATH HERE*>"


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
