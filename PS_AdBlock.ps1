<########################################################################################
## Author:            Makorus                                                          ##
## XDA Profile Link:  http://forum.xda-developers.com/member.php?u=4881417             ##
## XDA DevDB Link:    http://forum.xda-developers.com/showpost.php?p=60616282          ##
## GitHub Link:       https://github.com/makorus/PS-AdBlock                            ##
########################################################################################>

#region Functions and Startup Commands
#Get current time, needed to calculate the execution time at the end
$ScriptStartTime = (Get-Date)

#DebugMode skips the download and patch process, set "-Value" to "$true" to activate
New-Variable "DebugMode" -Option "Constant" -Value "$false"

#Automatic 'hosts' backup routine, set to "$false" to disable
New-Variable "HostsBackup" -Option "Constant" -Value "$true"

#Automatic 'hosts' apply routine, set to "$false" to disable
New-Variable "HostsAutoApply" -Option "Constant" -Value "$true"

#Current script version
New-Variable "PSScriptVersion" -Option "Constant" -Value "1.6.4"

#Line separator for better readability
New-Variable "LineSeparator" -Option "Constant" -Value "***************************************************************************************************"

#Get working path for PS1 file
$PSScriptRoot = Split-Path (Resolve-Path $myInvocation.MyCommand.Path)

#Get correct working path for compiled EXE file if necessary
If ($PSScriptRoot -match "Quest Software") {$PSScriptRoot = $([System.AppDomain]::CurrentDomain.BaseDirectory).TrimEnd("\")}

#Set working path
Set-Location -Path $PSScriptRoot

#Load logging functions
Function Log-Start
{
  <#
  .SYNOPSIS
    Creates log file

  .DESCRIPTION
    Creates log file with path and name that is passed. Checks if log file exists, and if it does deletes it and creates a new one.
    Once created, writes initial logging data

  .PARAMETER LogPath
    Mandatory. Path of where log is to be created. Example: C:\Windows\Temp

  .PARAMETER LogName
    Mandatory. Name of log file to be created. Example: Test_Script.log
      
  .PARAMETER ScriptVersion
    Mandatory. Version of the running script which will be written in the log. Example: 1.5

  .INPUTS
    Parameters above

  .OUTPUTS
    Log file created

  .NOTES
    Version:        1.0
    Author:         Luca Sturlese
    Creation Date:  10/05/12
    Purpose/Change: Initial function development

    Version:        1.1
    Author:         Luca Sturlese
    Creation Date:  19/05/12
    Purpose/Change: Added debug mode support

  .EXAMPLE
    Log-Start -LogPath "C:\Windows\Temp" -LogName "Test_Script.log" -ScriptVersion "1.5"
  #>
    
  [CmdletBinding()]
  
  Param ([Parameter(Mandatory=$true)][string]$LogPath, [Parameter(Mandatory=$true)][string]$LogName, [Parameter(Mandatory=$true)][string]$ScriptVersion)
  
  Process
  {
    $sFullPath = $LogPath + "\" + $LogName
    
    #Check if file exists and delete if it does
    If ((Test-Path -Path $sFullPath))
	{
      Remove-Item -Path $sFullPath -Force
    }
    
    #Create file and start logging
    New-Item -Path "$sFullPath" -ItemType File
    
    Add-Content -Path $sFullPath -Value "$LineSeparator"
    Add-Content -Path $sFullPath -Value "Started processing at [$([DateTime]::Now)]"
    Add-Content -Path $sFullPath -Value "$LineSeparator"
    Add-Content -Path $sFullPath -Value ""
    Add-Content -Path $sFullPath -Value "Running psAdAway script version $ScriptVersion"
    Add-Content -Path $sFullPath -Value ""
    Add-Content -Path $sFullPath -Value "$LineSeparator"
    Add-Content -Path $sFullPath -Value ""
	Add-Content -Path $sFullPath -Value "Running PowerShell version $($PSVersionTable.PSVersion)"
	Add-Content -Path $sFullPath -Value ""
	Add-Content -Path $sFullPath -Value "$LineSeparator"
    Add-Content -Path $sFullPath -Value ""
  
    #Write to screen for debug mode
    Write-Debug "$LineSeparator"
    Write-Debug "Started processing at [$([DateTime]::Now)]"
    Write-Debug "$LineSeparator"
    Write-Debug ""
    Write-Debug "Running psAdAway script version $ScriptVersion"
    Write-Debug ""
    Write-Debug "$LineSeparator"
    Write-Debug ""
    Write-Debug "Running PowerShell version $($PSVersionTable.PSVersion)"
    Write-Debug ""
    Write-Debug "$LineSeparator"
    Write-Debug ""
  }
}

Function Log-Write
{
  <#
  .SYNOPSIS
    Writes to a log file

  .DESCRIPTION
    Appends a new line to the end of the specified log file
  
  .PARAMETER LogPath
    Mandatory. Full path of the log file you want to write to. Example: C:\Windows\Temp\Test_Script.log
  
  .PARAMETER LineValue
    Mandatory. The string that you want to write to the log
      
  .INPUTS
    Parameters above

  .OUTPUTS
    None

  .NOTES
    Version:        1.0
    Author:         Luca Sturlese
    Creation Date:  10/05/12
    Purpose/Change: Initial function development
  
    Version:        1.1
    Author:         Luca Sturlese
    Creation Date:  19/05/12
    Purpose/Change: Added debug mode support

  .EXAMPLE
    Log-Write -LogPath "C:\Windows\Temp\Test_Script.log" -LineValue "This is a new line which I am appending to the end of the log file."
  #>
  
  [CmdletBinding()]
  
  Param ([Parameter(Mandatory=$true)][string]$LogPath, [Parameter(Mandatory=$true)][string]$LineValue)
  
  Process
  {
    Add-Content -Path $LogPath -Value $LineValue
  
    #Write to screen for debug mode
    Write-Host $LineValue
  }
}

Function Log-Error
{
  <#
  .SYNOPSIS
    Writes an error to a log file

  .DESCRIPTION
    Writes the passed error to a new line at the end of the specified log file
  
  .PARAMETER LogPath
    Mandatory. Full path of the log file you want to write to. Example: C:\Windows\Temp\Test_Script.log
  
  .PARAMETER ErrorDesc
    Mandatory. The description of the error you want to pass (use $_.Exception)
  
  .PARAMETER ExitGracefully
    Mandatory. Boolean. If set to True, runs Log-Finish and then exits script

  .INPUTS
    Parameters above

  .OUTPUTS
    None

  .NOTES
    Version:        1.0
    Author:         Luca Sturlese
    Creation Date:  10/05/12
    Purpose/Change: Initial function development
    
    Version:        1.1
    Author:         Luca Sturlese
    Creation Date:  19/05/12
    Purpose/Change: Added debug mode support. Added -ExitGracefully parameter functionality

  .EXAMPLE
    Log-Error -LogPath "C:\Windows\Temp\Test_Script.log" -ErrorDesc $_.Exception -ExitGracefully $true
  #>
  
  [CmdletBinding()]
  
  Param ([Parameter(Mandatory=$true)][string]$LogPath, [Parameter(Mandatory=$true)][string]$ErrorDesc, [Parameter(Mandatory=$true)][boolean]$ExitGracefully)
  
  Process
  {
    Add-Content -Path $LogPath -Value "Error: An error has occurred [$ErrorDesc]"
  
    #Write to screen for debug mode
    Write-Debug "Error: An error has occurred [$ErrorDesc]."
    
    #If $ExitGracefully = True then run Log-Finish and exit script
    If ($ExitGracefully -eq $true)
	{
      Log-Finish -LogPath $LogPath
      Break
    }
  }
}

Function Log-Finish
{
  <#
  .SYNOPSIS
    Write closing logging data & exit

  .DESCRIPTION
    Writes finishing logging data to specified log and then exits the calling script
  
  .PARAMETER LogPath
    Mandatory. Full path of the log file you want to write finishing data to. Example: C:\Windows\Temp\Test_Script.log

  .PARAMETER NoExit
    Optional. If this is set to True, then the function will not exit the calling script, so that further execution can occur
  
  .INPUTS
    Parameters above

  .OUTPUTS
    None

  .NOTES
    Version:        1.0
    Author:         Luca Sturlese
    Creation Date:  10/05/12
    Purpose/Change: Initial function development
    
    Version:        1.1
    Author:         Luca Sturlese
    Creation Date:  19/05/12
    Purpose/Change: Added debug mode support
  
    Version:        1.2
    Author:         Luca Sturlese
    Creation Date:  01/08/12
    Purpose/Change: Added option to not exit calling script if required (via optional parameter)

  .EXAMPLE
    Log-Finish -LogPath "C:\Windows\Temp\Test_Script.log"

.EXAMPLE
    Log-Finish -LogPath "C:\Windows\Temp\Test_Script.log" -NoExit $true
  #>
  
  [CmdletBinding()]
  
  Param ([Parameter(Mandatory=$true)][string]$LogPath, [Parameter(Mandatory=$false)][string]$NoExit)
  
  Process
  {
    Add-Content -Path $LogPath -Value ""
    Add-Content -Path $LogPath -Value "$LineSeparator"
    Add-Content -Path $LogPath -Value "Finished processing at [$([DateTime]::Now)]"
    Add-Content -Path $LogPath -Value "$LineSeparator"
  
    #Write to screen for debug mode
    Write-Debug ""
    Write-Debug "$LineSeparator"
    Write-Debug "Finished processing at [$([DateTime]::Now)]"
    Write-Debug "$LineSeparator"
  
    #Exit calling script if NoExit has not been specified or is set to False
    If (!($NoExit) -or ($NoExit -eq $false)) { Exit }
  }
}

#Function to check if the script is running with administrator privileges
Function CheckPrivileges
{
  $RunningAsAdmin = [bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -match "S-1-5-32-544")
  return $RunningAsAdmin
}

#Variable containing the logfile name
$PSLogFileName = "LogFile_$($MyInvocation.MyCommand.Name).log"

#Variable containing the working directory plus a "\" at the end, where this script is being executed from
$WorkPath = $PSScriptRoot + "\"

#Variable containing the path to the hostslist.ini file
$HostsList = $WorkPath + "hostslist.ini"

#Variable containing the path to the whitelist.ini file
$WhiteList = $WorkPath + "whitelist.ini"

#Variable containing the path to the 'DL_Cache' folder to cache the 'hosts' source files
$DLPath = $WorkPath + "DL_Cache\"

#Path to the merged 'hosts'-file
$MergedHostsFile = $WorkPath + "MergedList.txt"

#Path to the final 'hosts'-file
$FinalHostsFile = $WorkPath + "hosts"

#Variable to enumerate 'hosts' sources
$DLIndex = 1

#Build path to 'hosts'-file
$HostsFilePath = $env:SystemRoot + "\system32\drivers\etc\"

#Current 'hosts'-file
$CurrentHostsFile = $HostsFilePath + "hosts"

#Old 'hosts'-file
$OldHostsFile = $HostsFilePath + "hosts.old"

#Original 'hosts'-file
$OriginalHostsFile = $HostsFilePath + "hosts.original"
$OriginalHostsSource = $WorkPath + "hosts.original"

#Default Windows 'hosts'-file
$DefaultWindowsHostsFile = "# Copyright (c) 1993-2009 Microsoft Corp.
#
# This is a sample HOSTS file used by Microsoft TCP/IP for Windows.
#
# This file contains the mappings of IP addresses to host names. Each
# entry should be kept on an individual line. The IP address should
# be placed in the first column followed by the corresponding host name.
# The IP address and the host name should be separated by at least one
# space.
#
# Additionally, comments (such as these) may be inserted on individual
# lines or following the machine name denoted by a '#' symbol.
#
# For example:
#
#      102.54.94.97     rhino.acme.com          # source server
#       38.25.63.10     x.acme.com              # x client host

# localhost name resolution is handled within DNS itself.
#	127.0.0.1       localhost
#	::1             localhost"

#Start logging function, generate log file and set script version number
Log-Start -LogPath "$PSScriptRoot" -LogName "$PSLogFileName" -ScriptVersion "$PSScriptVersion"

#Warning for unsupported PowerShell version
If ($($PSVersionTable.PSVersion.Major) -lt 3)
{
  Log-Write -LogPath ".\$PSLogFileName" -LineValue "$LineSeparator"
  Log-Write -LogPath ".\$PSLogFileName" -LineValue "---> !!! ATTENTION !!! <---"
  Log-Write -LogPath ".\$PSLogFileName" -LineValue "You're using an unsupported PowerShell version (your version is $($PSVersionTable.PSVersion.Major))!"
  Log-Write -LogPath ".\$PSLogFileName" -LineValue "Please upgrade your PowerShell version!"
  Log-Write -LogPath ".\$PSLogFileName" -LineValue "---> !!! ATTENTION !!! <---"
}
#endregion Functions and Startup Commands

#region Host Sources
#########################################################################################
## Host Sources:                                                                       ##
## - Contains a list of recommended hosts sources (credits to their respective owners) ##
## - These will be downloaded and saved into a sub directory 'DL_Cache'                ##
#########################################################################################
## Notes:                                                                              ##
## - Add these host names to the patch list below to avoid conflicts                   ##
## - When adding custom sources, please make sure that the very last enTry of this     ##
##   array has NO comma (,) at the end, only host sources above the last line need it! ##
#########################################################################################
[String[]]$HostSources = ""

Log-Write -LogPath ".\$PSLogFileName" -LineValue "$LineSeparator"
Log-Write -LogPath ".\$PSLogFileName" -LineValue "Checking for existing hostslist.ini file..."
If (Test-Path -Path $HostsList)
{
  Log-Write -LogPath ".\$PSLogFileName" -LineValue "Found existing hostslist.ini file - reading file..."
  ForEach ($currLine in $(Get-Content -Path $HostsList))
  {
    $HostSources += $currLine
  }
  $HostSources = $HostSources | Where-Object { $_ }
  Log-Write -LogPath ".\$PSLogFileName" -LineValue "Successfully queried hostslist.ini file!"
}
Else
{
  Log-Write -LogPath ".\$PSLogFileName" -LineValue "Didn't find existing hostslist.ini file - using default list..."
  [String[]]$DefaultHostSources = "http://hostsfile.org/Downloads/hosts.txt",
  "http://someonewhocares.org/hosts/zero/hosts",
  "http://winhelp2002.mvps.org/hosts.txt",
  "http://adaway.org/hosts.txt",
  "http://pgl.yoyo.org/as/serverlist.php?hostformat=hosts&showintro=0&mimetype=plaintext",
  "http://www.malwaredomainlist.com/hostslist/hosts.txt"
  $HostSources = $DefaultHostSources
}
#endregion Host Sources

#region Patch Table
#########################################################################################
## Patch Table:                                                                        ##
## - This PowerShell hash table is being used to patch the entire merged hosts list    ##
## - This is also the whitelist                                                        ##
## - Replaces tabulators with a single space                                           ##
## - Replaces 2 or more spaces with a single space                                     ##
## - Replace 127.0.0.1 with 0.0.0.0 (to avoid long DNS-request times)                  ##
#########################################################################################
## Notes:                                                                              ##
## - To add custom host names to your whitelist, edit the whitelist.ini file or        ##
##   simply add a new enTry, e.g.:                                                     ##
##   $PatchTable.Add('your-web-site.com', '')                                          ##
##   Syntax: $PatchTable.Add('replace-THIS', '')                                       ##
#########################################################################################
Log-Write -LogPath ".\$PSLogFileName" -LineValue "$LineSeparator"
Log-Write -LogPath ".\$PSLogFileName" -LineValue "Checking for existing whitelist.ini file..."
If (Test-Path -Path $WhiteList)
{
  $PatchTable = New-Object System.Collections.Specialized.OrderedDictionary
  Log-Write -LogPath ".\$PSLogFileName" -LineValue "Found existing whitelist.ini file - reading file..."
  ForEach ($currLine in $(Get-Content -Path $WhiteList))
  {
	$PatchTable.Add("$currLine", "")
  }
  Log-Write -LogPath ".\$PSLogFileName" -LineValue "Successfully queried whitelist.ini file!"
}
Else
{
  Log-Write -LogPath ".\$PSLogFileName" -LineValue "Didn't find existing whitelist.ini file - using default list..."
  $DefaultPatchTable = New-Object System.Collections.Specialized.OrderedDictionary
  $DefaultPatchTable.Add("hostsfile.org", "")
  $DefaultPatchTable.Add("someonewhocares.org", "")
  $DefaultPatchTable.Add("winhelp2002.mvps.org", "")
  $DefaultPatchTable.Add("adaway.org", "")
  $DefaultPatchTable.Add("pgl.yoyo.org", "")
  $DefaultPatchTable.Add("malwaredomainlist.com", "")
  $DefaultPatchTable.Add("bit.ly", "")
  $DefaultPatchTable.Add("spotify.com", "")
  $DefaultPatchTable.Add("skype.com", "")
  $DefaultPatchTable.Add("m.hotmail.com", "")
  $DefaultPatchTable.Add("s.gateway.messenger.live.com", "")
  $DefaultPatchTable.Add("s.youtube.com", "")
  $DefaultPatchTable.Add("goo.gl", "")
  $PatchTable = $DefaultPatchTable
}
#endregion Patch Table

#region Main Script
Try
{
  #region Download Cache
  #Check if the 'DL_Cache' folder exists, if not, create one
  Log-Write -LogPath ".\$PSLogFileName" -LineValue "$LineSeparator"
  Log-Write -LogPath ".\$PSLogFileName" -LineValue "Checking whether the '$DLPath' folder exists..."
  
  If (!(Test-Path -Path $DLPath))
  {    
    Log-Write -LogPath ".\$PSLogFileName" -LineValue "Download cache folder not found. Creating empty download cache folder..."
    New-Item -Path $DLPath -ItemType Directory
    Log-Write -LogPath ".\$PSLogFileName" -LineValue "Successfully created the download cache folder!"
  }
  Else
  {
    Log-Write -LogPath ".\$PSLogFileName" -LineValue "Existing download cache folder found!"
  }
  #endregion Download Cache
  
  #region Download Process
  #Download process for 'hosts' sources with additional handler for $DebugMode
  Log-Write -LogPath ".\$PSLogFileName" -LineValue "$LineSeparator"
  If ($DebugMode -eq $false)
  {
    Log-Write -LogPath ".\$PSLogFileName" -LineValue "Starting download process for 'hosts' sources..."
    $WebClient = New-Object System.Net.WebClient
    $WebClient.Credentials = New-Object System.Net.Networkcredential("", "")
    
    ForEach($Source in $HostSources)
    {
      Log-Write -LogPath ".\$PSLogFileName" -LineValue "Downloading hosts file from: $Source"
      $SourcePath = $DLPath + $DLIndex + "_source-hosts.txt"

      Log-Write -LogPath ".\$PSLogFileName" -LineValue "Downloading hosts file to: $SourcePath"
      
      Try
      {
        $WebClient.DownloadFile($Source, $SourcePath)
      }
      Catch [System.Net.WebException],[System.Exception]
      {
        Log-Write -LogPath ".\$PSLogFileName" -LineValue "---> !!! Source `"$Source`" seems to be offline !!! <---"
        Log-Write -LogPath ".\$PSLogFileName" -LineValue "Trying next one..."
      }

      $DLIndex += 1
    }

    Log-Write -LogPath ".\$PSLogFileName" -LineValue "Finished download process!"
  }
  ElseIf ($DebugMode -eq $true)
  {
    Log-Write -LogPath ".\$PSLogFileName" -LineValue "Debug mode activated, skipped download process..."
  }
  #endregion Download Process

  #region Merge & Patch
  #Merge all 'hosts'-files
  Log-Write -LogPath ".\$PSLogFileName" -LineValue "$LineSeparator"
  Log-Write -LogPath ".\$PSLogFileName" -LineValue "Merging all hosts files into one big file, ignoring comment lines and duplicates, sorting and trimming lines..."
  $PlainText = Get-Content "$DLPath*.txt" | Where-Object { $_ -notmatch '#' } | Sort-Object | Get-Unique | ForEach-Object { $_.Trim() }
  
  #Apply patch table with additional handler for $DebugMode
  If ($DebugMode -eq $false)
  {
    Log-Write -LogPath ".\$PSLogFileName" -LineValue "Applying patch table..."
	
	$PlainText = $PlainText -ireplace '\t', ' '
    $PlainText = $PlainText -ireplace ' {2,}', ' '
    $PlainText = $PlainText -ireplace "127.0.0.1", "0.0.0.0"
	
    ForEach($ToBeReplaced in $PatchTable.Keys)
    {
      Log-Write -LogPath ".\$PSLogFileName" -LineValue "Applying patch for '$ToBeReplaced'..."
      If ($ToBeReplaced -eq "localhost")
	  {
        $NewHost = $ToBeReplaced.Replace("calho", "cal.\ho")
        $PlainText = $PlainText -ireplace $("^*([A-Za-z0-9.-]*)?$ToBeReplaced\Z"), $NewHost
      }
      Else
	  {
        $NewHost = $ToBeReplaced.Replace(".", ".\")
        $PlainText = $PlainText -ireplace $("^0.0.0.0 ([A-Za-z0-9.-]*\.)?$ToBeReplaced"), $NewHost
      }
    }
    Log-Write -LogPath ".\$PSLogFileName" -LineValue "Successfully finished apply process!"
  }
  ElseIf ($DebugMode -eq $true)
  {
    Log-Write -LogPath ".\$PSLogFileName" -LineValue "Debug mode activated, skipped patch process..."
  }

  #Create final, clean UTF8-encoded 'hosts'-file
  Log-Write -LogPath ".\$PSLogFileName" -LineValue "Creating new 'hosts'-file..."
  $PlainText | Where-Object { $_ } | Sort-Object | ForEach-Object { $_.ToLower() } | Get-Unique | Out-File $FinalHostsFile -Encoding UTF8
  [System.IO.File]::WriteAllLines($FinalHostsFile, $(Get-Content $FinalHostsFile), $(New-Object System.Text.UTF8Encoding($false)))
  Log-Write -LogPath ".\$PSLogFileName" -LineValue "Successfully created the 'hosts'-file!"
  #endregion Merge & Patch

  #region DNS Check
  #Check if the client DNS Cache is enabled and log the result and warnings
  Log-Write -LogPath ".\$PSLogFileName" -LineValue "$LineSeparator"
  $DNSServiceStatus = Get-WMIObject Win32_Service -Filter "name='Dnscache'" -Computer "."
  If ($DNSServiceStatus.StartMode -ne "Disabled")
  {
    Log-Write -LogPath ".\$PSLogFileName" -LineValue "---> !!! ATTENTION !!! <---"
	Log-Write -LogPath ".\$PSLogFileName" -LineValue "DNS Cache service is enabled!"
	Log-Write -LogPath ".\$PSLogFileName" -LineValue "It's safe to apply your new hosts file now."
	Log-Write -LogPath ".\$PSLogFileName" -LineValue "Although if (only IF) you experience any issues, you should consider disabling this service!"
	Log-Write -LogPath ".\$PSLogFileName" -LineValue "If you experience performance issues, disable the client DNS Cache service via CMD:"
    Log-Write -LogPath ".\$PSLogFileName" -LineValue "sc config dnscache start= disabled"
    Log-Write -LogPath ".\$PSLogFileName" -LineValue "Or via PowerShell:"
	Log-Write -LogPath ".\$PSLogFileName" -LineValue "Set-Service -Name `"Dnscache`" -StartupType `"Disabled`""
	Log-Write -LogPath ".\$PSLogFileName" -LineValue "---> !!! ATTENTION !!! <---"
  }
  ElseIf ($DNSServiceStatus.StartMode -eq "Disabled")
  {
    Log-Write -LogPath ".\$PSLogFileName" -LineValue "---> !!! ATTENTION !!! <---"
	Log-Write -LogPath ".\$PSLogFileName" -LineValue "DNS Cache service is disabled."
	Log-Write -LogPath ".\$PSLogFileName" -LineValue "You should consider enabling the client DNS Cache service and check if you encounter any performance issues!"
	Log-Write -LogPath ".\$PSLogFileName" -LineValue "---> !!! ATTENTION !!! <---"
  }
  #endregion DNS Check

  #region Backup & Apply
  #Check if the current script is being executed with administrator privileges
  Log-Write -LogPath ".\$PSLogFileName" -LineValue "$LineSeparator"
  Log-Write -LogPath ".\$PSLogFileName" -LineValue "Checking whether the script is being executed with administrator privileges..."
  $IsInAdminMode = CheckPrivileges
  
  If ($IsInAdminMode -eq $true)
  {
    Log-Write -LogPath ".\$PSLogFileName" -LineValue "Administrator privileges found!"
	
	Log-Write -LogPath ".\$PSLogFileName" -LineValue "Checking automatic 'hosts' backup routine..."
	If ($HostsBackup -eq $true)
	{
	  Log-Write -LogPath ".\$PSLogFileName" -LineValue "Automatic 'hosts' backup is enabled!"
	  If (Test-Path -Path $OriginalHostsFile)
	  {
	    Log-Write -LogPath ".\$PSLogFileName" -LineValue "Original 'hosts'-file already found!"
	  }
	  Else
	  {
        If (!(Test-Path -Path $OriginalHostsSource))
        {
          Log-Write -LogPath ".\$PSLogFileName" -LineValue "No original 'hosts'-file found; creating a new default Windows 'hosts'-file..."
          $DefaultWindowsHostsFile | Out-File $OriginalHostsSource -Encoding UTF8
          [System.IO.File]::WriteAllLines($OriginalHostsSource, $(Get-Content $OriginalHostsSource), $(New-Object System.Text.UTF8Encoding($false)))
        }
	  	Log-Write -LogPath ".\$PSLogFileName" -LineValue "Saving original 'hosts'-file..."
        Copy-Item -Path $OriginalHostsSource -Destination $OriginalHostsFile
		Log-Write -LogPath ".\$PSLogFileName" -LineValue "Saved original 'hosts'-file: $OriginalHostsFile"
	  }
	  Log-Write -LogPath ".\$PSLogFileName" -LineValue "Creating backup of current 'hosts'-file..."
	  Move-Item -Path $CurrentHostsFile -Destination $OldHostsFile -Force -Confirm:$false -ErrorAction SilentlyContinue
	  Log-Write -LogPath ".\$PSLogFileName" -LineValue "Saved current 'hosts'-file: $OldHostsFile"
	}
	ElseIf ($HostsBackup -eq $false)
	{
	  Log-Write -LogPath ".\$PSLogFileName" -LineValue "Automatic 'hosts' backup is disabled!"
	}
	
	Log-Write -LogPath ".\$PSLogFileName" -LineValue "Checking automatic 'hosts' apply routine..."
	If ($HostsAutoApply -eq $true)
	{
	  Log-Write -LogPath ".\$PSLogFileName" -LineValue "Automatic 'hosts' apply is enabled!"
	  Log-Write -LogPath ".\$PSLogFileName" -LineValue "Applying new 'hosts'-file..."
	  Copy-Item -Path $FinalHostsFile -Destination $CurrentHostsFile -Force -Confirm:$false
	  Log-Write -LogPath ".\$PSLogFileName" -LineValue "Successfully applied new 'hosts'-file!"
	}
	ElseIf ($HostsAutoApply -eq $false)
	{
	  Log-Write -LogPath ".\$PSLogFileName" -LineValue "Automatic 'hosts' apply is disabled!"
	}
  }
  Else
  {
    Log-Write -LogPath ".\$PSLogFileName" -LineValue "Administrator privileges not found!"
	Log-Write -LogPath ".\$PSLogFileName" -LineValue "Script will be unable to create a backup and automatically apply the 'hosts'-file!"
  }
  #endregion Backup & Apply

  #Capture current time
  $ScriptEndTime = (Get-Date)

  Log-Write -LogPath ".\$PSLogFileName" -LineValue "$LineSeparator"
  Log-Write -LogPath ".\$PSLogFileName" -LineValue "Finished the PowerShell AdBlock script!"
  Log-Write -LogPath ".\$PSLogFileName" -LineValue "Elapsed time: $(($ScriptEndTime-$ScriptStartTime).TotalSeconds) seconds"
  Log-Finish -LogPath ".\$PSLogFileName"
}
Catch
{
  Log-Write -LogPath ".\$PSLogFileName" -LineValue "---> !!! ATTENTION !!! <---"
  Log-Write -LogPath ".\$PSLogFileName" -LineValue "An unexpected error has occured!"
  Log-Write -LogPath ".\$PSLogFileName" -LineValue "---> !!! ATTENTION !!! <---"
  Log-Error -LogPath ".\$PSLogFileName" -ErrorDesc $_.Exception -ExitGracefully $true
}
#endregion Main Script
