# =============================================================================
# File:     OSDResultsTally.ps1
# Version:  1.0
# Date:     4 December 2018
# Author:   Mike Marable
#
# Purpose: Tallys success vs. failure of build results in a CSV on the network
#          Written for MiSCUG presentation on 11 Jan 2019
#


# Version:  
# Date:     
# Author:   
#
# Purpose: 
#


# =============================================================================
# Initialization

param (
    [string]$Record = $(throw "-Record is required [Success/Failure].")
    )


# =============================================================================
# Functions

# =============================================================================
# Start of Code

# Set Variables
    # Script Variables
    $myScript      = "OSDResults"
    $MyVersion     = "1.0"

    # Task Sequence Variables
    $tsenv         = New-Object -COMObject Microsoft.SMS.TSEnvironment
    $OSDVer        = $tsenv.Value("OSDVer")
    $TargetFolder  = $tsenv.Value("OSDResultsShare")
    $OSDBranch     = $tsenv.Value("OSDBranch")
    
    # Logging Variables
    $CSVfileName   = "OSDResultsTally_$OSDVer.csv"
    $OutPut        = "$TargetFolder\BuildStats\$OSDBranch"
    $CSVFile       = "$OutPut\$CSVfileName"

# =============================================================================
Write-Host "=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
Write-Host "Starting $MyScript (v $MyVersion)"
Write-Host "=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="

# =============================================================================
# Data Collection

    # Gather the results for this build
	Write-Host "Gathering the results for this build..."

    # Computer Name
    Write-Host "    ...Computer Name"
    # Attempt to pull the targeted computer name, if that hasn't been set yet grab the MINNT name
    $CompName = $tsenv.Value("OSDComputerName")
    IF ($CompName -eq $NULL)
        {
        $CompName = $env:COMPUTERNAME
        }

    # Start Date/Time
    $OSDStartInfo   = $tsenv.Value("OSDStartInfo")
    # Finish Date/Time
    $OSDFinishInfo = (Get-Date -Format "dd-MMM-yyyy HH:mm:ss")

    # Elapsed time
	$TimeDiff = New-TimeSpan -Start $OSDStartInfo -End $OSDFinishInfo
		# Break the elapsed time down into units
		$Days = $TimeDiff.Days
		$Hrs  = $TimeDiff.Hours
		$Mins = $TimeDiff.Minutes
		$Sec  = $TimeDiff.Seconds

		# Boil it all down into the number of minutes the build took
		# Days (just in case)
		IF ($Days -gt 0) {$dMins = ($Days * 24) * 60}
		# Hours
		IF ($Hrs -gt 0) {$hMins = $Hrs * 60}
		# Seconds into a fraction of a minute
		$mSec = $Sec / 60
		# Limit to 2 decimal places
		$mSec = "{0:N2}" -f $mSec

	# Add it all up to get the number of minutes the build took
	#$ElapsedTime = $dMins + $hMins + $Mins + $mSec
    $ElapsedTime = $TimeDiff.TotalMinutes
    $ElapsedTime = "{0:N2}" -f $ElapsedTime
    $ElapsedTime = $ElapsedTime -replace '[,]'

    # Model
    Write-Host "    ...Hardware Model"
    $OSDModelInfo = (Get-WmiObject -Class Win32_ComputerSystem).Model

    # TSID
    $TSID           = $tsenv.Value("_SMSTSPackageID")

    # TSname
    $TSName         = $tsenv.Value("_SMSTSPackageName")

    # OSDResult
    $OSDResults = $Record

    # Failure Reason
    IF ($Record -eq "Failure") { $SmstFailAction   = $tsenv.Value("FailedStepName") }

	IF ($Record -eq "Success") { $SmstFailAction   = "Success" }

    # Slow Site
    $OSSlowSiteInfo = $tsenv.Value("SlowSite")

    # USMT Backup
    $USMTBackup     = $tsenv.Value("USMTBackup")

    # USMT Restore
    $USMTRestore    = $tsenv.Value("USMTRestore")

Write-Host "+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+"
Write-Host "Results to be recorded:"
Write-Host " "
Write-Host " Computer Name:     " $CompName
Write-Host " Start Date/Time:   " $OSDStartInfo
Write-Host " Finish Date/Time:  " $OSDFinishInfo
Write-Host " Elapsed time:      " $ElapsedTime
Write-Host " Model:             " $OSDModelInfo
Write-Host " TSID:              " $TSID
Write-Host " TSname:            " $TSName
Write-Host " OSDResult:         " $OSDResults
Write-Host " Failure Reason:    " $SmstFailAction
Write-Host " Slow Site:         " $OSSlowSiteInfo
Write-Host " USMT Backup:       " $USMTBackup
Write-Host " USMT Restore:      " $USMTRestore
Write-Host "+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+"

# =============================================================================
# Data File Initialization

    # Create the report folder if it does not exist
    Write-Host "Checking to see if the log folder ( $OutPut ) needs to be created..."
    IF (!(Test-Path $OutPut))
        {
        Write-Host "Folder does not exist"
        Write-Host "Creating...."
        New-Item -Path $OutPut -ItemType Directory
        }

    # Create the file if one does not exist
    Write-Host "Checking to see if the log file ( $CSVfile ) needs to be created..."
    IF (!(Test-Path $CSVfile))
        {
        Write-Host "File does not exist"
        Write-Host "Creating..."
        Add-Content -Value "CompName,StartDateTime,EndDateTime,ElapsedTime,Model,TSID,TSName,OSDResults,FailureReason,SlowSite,USMTBackup,USMTRestore" -Path $CSVFile
        }

# =============================================================================
# Data Write
Add-Content -Value "$CompName,$OSDStartInfo,$OSDFinishInfo,$ElapsedTime,$OSDModelInfo,$TSID,$TSName,$OSDResults,$SmstFailAction,$OSSlowSiteInfo,$USMTBackup,$USMTRestore" -Path $CSVFile

# =============================================================================
Write-Host "=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
Write-Host "Finished $MyScript (v $MyVersion)"
Write-Host "=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="

# Finished
# =============================================================================
