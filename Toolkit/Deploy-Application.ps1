<#
.SYNOPSIS

Installing ANSYS 2024 R2

.DESCRIPTION

Bundling and Installing ANSYS 2024 R2 through PSADT


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
    [String]$appName = 'ANSYS PREPPOST '
    [String]$appVersion = '2024 R2'
    [String]$appArch = 'x64'
    [String]$appLang = 'EN'
    [String]$appRevision = '01'
    [String]$appScriptVersion = '1.0.0'
    [String]$appScriptDate = '11/01/2024'
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

        # Installation boxes will ONLY show if DeploymentMode is set to "Interactive"

        Show-InstallationPrompt -Title "ANSYS 2024 R2 Prep Post Installation" -Message "ANSYS 2024 R2 Prep Post will begin to Install. `n`n Please wait until installation is finished" -NoWait -Timeout 10

        Show-InstallationProgress -StatusMessage "ANSYS 2024 R2 Prep Post Installation in Progress... `n`n Please be patient."

        [String]$installPhase = 'Installation'

        #Install ANSYS 2024 R2 Prep Post
        Execute-Process -Path "$dirFiles\PREPPOST_2024R2_WINX64\setup.exe" `
        -Parameters "-silent -install_dir `"C:\Program Files\ANSYS Inc`" -licserverinfo `"2325:1055:vmw00250`"" `
        -WindowStyle Hidden `
        -Passthru

        <#

            ANSYS License Server - vmw00250
            Default Ports - 2325,1055 

            ## QUICK NOTE ABOUT THE PORTS ##
            
            1055 is the normal default FLEXNet port

            2325 is the default Licensing Interconnect port

            When doing a normal install for ANSYS, only the 1055 port is required
            
            But when running the 'setup.exe' from powershell and putting the license server info as part of a parameter
            then the other port is also required

            Here is the normal ANSYS powershell command:
            
            ** Make sure you are in the directory of the 'setup.exe' **
            
            'setup.exe -silent -install_dir "C:\Program Files\ANSYS Inc" -licserverinfo 2325:1055:vmw00250'

            ** Can also use a license file as well **
            
            'setup.exe -silent -install_dir "C:\Program Files\ANSYS Inc" -licfilepath "path_to/license_file.lic"' 

        #>

        [String]$installPhase = 'Post-Installation'

        # Create a shortcut for the Application
        New-Shortcut -Path "C:\Users\Public\Public Desktop\Ansys 2024 R2\Ansys Workbench.lnk" -TargetPath "C:\Program Files\ANSYS Inc\v242\Framework\bin\Win64\RunWB2.exe" -Description "Ansys Workbench"

        Show-DialogBox -Title "Installation Notice" -Text "Installation is complete" -Buttons "OK" -Icon Information -Timeout 100

     

        #Silent Ansys Uninstaller 
        #New-Shortcut -Path "$dirFiles\Ansys Uninstaller\Ansys Unistall.lnk" -TargetPath "C:\Program Files\ANSYS Inc\v242\Uninstall.exe" -Arguments "-silent" -Description "Ansys Uninstaller"

        #Normal Ansys Uninstaller
        #New-Shortcut -Path "$dirFiles\Ansys Uninstaller\Ansys Unistall.lnk" -TargetPath "C:\Program Files\ANSYS Inc\v242\Uninstall.exe" -Description "Ansys Uninstaller"


        #New-Shortcut -Path "C:\Users\$username\Desktop\Ansys 2024 R2.lnk" -TargetPath "C:\Program Files\ANSYS Inc\v242\Framework\bin\Win64\RunWB2.exe"
    
        

    }
    ElseIf ($deploymentType -ieq 'Uninstall') {
        
        [String]$installPhase = 'Pre-Uninstallation'

        # Stop any and all Ansys Processes
        Get-Process | Where-Object {$_.Name -like "*Ansys*"} | Stop-Process -Force

        Show-InstallationPrompt -Title "ANSYS 2024 R2 Prep Post" -Message "Beginning Uninstallation for ANSYS 2024 R2 Prep Post `n`n Please wait until uninstallation is finished." -NoWait -Timeout 10

        Show-InstallationProgress -StatusMessage "ANSYS R2 2024 Prep Post Uninstallation in Progress"

        [String]$installPhase = 'Uninstallation'
        
        [string]$uninstallPath = "C:\Program Files\ANSYS Inc\v242\Uninstall.exe"

        #Uninstall ANSYS 2024 R2 Prep Post
        Execute-Process -Path $uninstallPath -Parameters "-silent"

        [String]$installPhase = 'Post-Uninstallation'

        Remove-File -Path "C:\Users\Public\Public Desktop\Ansys 2024 R2\Ansys Workbench.lnk"

        Show-DialogBox -Title "Uninstallation Notice" -Text "Uninstallation is complete" -Buttons "OK" -Icon Information -Timeout 10

        
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
