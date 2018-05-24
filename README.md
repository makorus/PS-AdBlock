# PS AdBlock
PowerShell-based AdBlock Script by Makorus<br />

XDA DevDB Link:    http://forum.xda-developers.com/showpost.php?p=60616282<br />

This script does exactly what you think: It grabs various "hosts" sources from the internet, saves them locally, and merges them to one big file. Enjoy an ad-free Windows experience.<br />

* Download as many "hosts" files as you want
* Merge them automatically into one big "hosts" file
* Remove duplicates from the "hosts" file
* Remove any comment line starting with # to keep your hosts file as small as possible
* Apply a custom whitelist or even custom blacklists
* Log the entire process to a log file (placed within the same directory where you saved this script)
* Optional auto apply and auto backup feature (can be disabled)


## Notes
* PowerShell 3.0 or newer is recommended to run this script without any errors
* PowerShell 2.0 may work as well, but is unsupported
* If you disable the backup/apply mode you have to manually copy the final 'hosts'-file to the Windows etc directory (please manually backup the old file:
  * C:\Windows\System32\drivers\etc
* To apply a custom blacklist, simply create a text file containing your desired hosts and save it in the download cache folder 'DL_Cache' (run the script once)
* To manually add your custom hosts list, create a new text file called 'hostslist.ini' and add your hosts sources (one site per line without the www)
* To automatically remove specific sites from the hosts list, create a new text file called 'whitelist.ini" and add your sites you want to whitelist 
* If you experience performance issues like extremely slow Windows startup time, try to disable the client DNS Cache service via CMD:
  * sc config dnscache start= disabled


## Change Log
**Most recent version first, date format _yyyy-MM-dd_**

### V1.6.4, 2018-05-24
* Moved comments from main PowerShell script file to README.md
* Fixed wrong version number in main PowerShell script file (typo)
* Added two new hosts source providers:
  * https://raw.githubusercontent.com/hoshsadiq/adblock-nocoin-list/master/hosts.txt
  * https://raw.githubusercontent.com/greatis/Anti-WebMiner/master/hosts

### V1.6.3, 2018-02-03
* Added logic to handle 'localhost' in whitelist (thanks to antonio-gil)
* Removed script version from filename

### V1.6.2, 2017-04-25
* Added Goo.gl to 'Patch Table' and to the default whitelist.ini:
  * $DefaultPatchTable.Add('\w+.goo.gl', 'localhost')
* Changed the foreach loop to avoid recreating the object System.Net.WebClient
* Added error handling for the download process
* Added routine to correctly check the existence of the original 'hosts'-file
* Removed EXE file because of false positive alarms from many AntiVirus engines
* Added instead two new batch files: '_Run_Admin.bat' and '_Run_User.bat'
* Overall rework, changes many comments and updated some notes

### V1.6.1, 2016-04-19
* Fixed wrong script number

### V1.6.0, 2016-02-29
* Added function to check for admin privileges
* Added routine for automatic apply of 'hosts'-file (admin privileges required)
* Added routine for backup of 'hosts'-file (admin privileges required)
* Added some Skype and YouTube hostnames to the whitelist for proper functionality
* Added new icon for the executable file
* Updated the notes (see below)
* Overall cleanup, added region codes for the main script

### V1.5.9, 2016-01-24
* Non-public test version only (skipped)

### V1.5.8, 2016-01-03
* Non-public test version only (skipped)

### V1.5.7, 2015-10-17
* Completely replaced previous regex patterns with one more complex pattern to handle hostnames with subdomains, performance increased significantly

### V1.5.6, 2015-10-11
* Added again regex patterns to patch table, whitelist should work now correctly
* Debug mode now skips the patch process as well

### V1.5.5, 2015-10-10
* Fixed issue with method ToLower (should work with PowerShell 2.0 now), ToLower is a method which works with strings only, work around via ForEach-Object cmdlet
* Added a PowerShell version check, unsupported versions are PowerShell v1 and v2, if you start this script with an unsupported PowerShell version, you'll find some hints in the log file to inform you about that

### V1.5.4, 2015-10-09
* Fixed duplicate hostname issue, cmdlet Get-Unique allows by default hostnames with capital letters (Get-Unique is a case sensitive search), e.g. 'test.com' and 'Test.com' are being handled correctly now
* Reverted warning about DNS cache service, there should be no issue with the DNS cache service because the 'hosts'-file is being encoded as a typical UTF8 file
* Added new debug mode, set $DebugMode to $true to activate it (This skips the download process, useful if you want to test something without re-downloading the whole host source lists)

### V1.5.3, 2015-10-08
* Fixed ugly encoding issue, new 'hosts'-file will be created correctly now, means no BOM (Byte Order Mark) and no UCS-2 encoding anymore, should fix many issues

### V1.5.2, 2015-09-13
* Remove every empty line in the hosts file
* Changed the Log-Write function to use Write-Host instead of Write-Debug, now the entire log will be shown during the script execution (live)
* Changed replacement method to insert 0.0.0.0 instead of 127.0.0.1 in the final hosts file which leads to a much better and faster DNS resolution
* Future releases will be delivered with additional hosts files, for example to block Google ad servers and some Windows 10 hosts to stop this privacy nightmare

### V1.5.1, 2015-08-11
* Fixed issue with wrong $PSScriptRoot variable when using the EXE variant
* Changed the 'release history' to allow better versioning (e.g. version 1.5.1)
  * Note: Older versions still contain two numbers only (e.g. version 1.2 etc.)

### V1.5.0, 2015-08-10
* The file now checks for the client DNS Cache service and logs a warning if it's enabled to ensure you don't run into troubles
* Removed the note about the DNS Cache service: It's not recommended to set the startup type to "demand" (manual), it will cause issues sooner or later
* Starting from now on, I'll create an executable file (to be found in the ZIP)
* I'll also attach a VirusTotal.com scan to every new release 
  * Please report any Anti-Virus false positive alarms to me

### V1.4.0, 2015-07-26
* Reworked whitelist method (check notes for more information)
* Reworked hosts source list (check notes for more information)
* Reworked the 'Patch Table', doesn't require regex expressions anymore

### V1.3.0, 2015-05-13
* Completely reworked the 'release history', huge improvement to readability
* The 'Patch Table' uses now '-ireplace' instead '-replace' for better results
* Changed the 'Patch Table' to use regex expressions for my default list
* Added Spotify to 'Patch Table':
  * $DefaultPatchTable.Add('\w+.spotify.com', 'localhost')

### V1.2.0, 2015-05-13
* Fixed issue with old 'New-Item' command in function 'Log-Start':
  * OLD: New-Item -Path $LogPath -Value $LogName -ItemType File
  * NEW: New-Item -Path "$sFullPath" -ItemType File
* Changed the 'Log-Start' invoking command to use $PSScriptRoot:
  * OLD: Log-Start -LogPath ".\" [...]
  * NEW: Log-Start -LogPath "$PSScriptRoot" [...]
* Added #region and #endregion codes to fold the code

### V1.1.0, 2015-05-10
* Added release history to the script
* Merged log functions to the main script file (no more two separate files)
* Added XDA:DevDB link
* Added script version to name (easy identification)

### V1.0.0, 2015-05-09
* First public and stable release

### V0.0.1 - V0.0.9, 2015-05-02
* Non-public test versions only (skipped)
