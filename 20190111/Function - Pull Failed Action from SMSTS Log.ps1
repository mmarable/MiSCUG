# =============================================================================
# Functions

#--------------------------------------
Function Get-SmstsFailAction
#--------------------------------------
	{
	Param ($SmstsLogPath)
	$LogContents = $null
	$FailedActionsIndexArray = $null
	$strLastFailAction = $null

	$LogContents = Get-Content -Path $SmstsLogPath -ReadCount 0
	Try
		{
		$FailedActionsIndexArray = @(0..($LogContents.Count - 1) | Where-Object {$LogContents[$_] -match "Failed to run the action"})
		$strLastFailAction = (($LogContents[($FailedActionsIndexArray[-1])].tostring())-replace '.*\[LOG\[') -replace 'Failed to run the action: ' -replace '\]LOG\].*'
		}
	Catch
		{
		$strLastFailAction = "Unkown"
		}
	Return $strLastFailAction
	}
    #end function Get-SmstsFailAction





# =============================================================================
# Start of Code
# Set Variables for the location of the SMSTS.log file/path
$SMSTSfldr     = $tsenv.Value("_SMSTSLogPath")
$SMSTSfile     = "$SMSTSfldr\smsts.log"

# Call the function to parse the SMSTS log for the failed TS action
$SmstFailAction = Get-SmstsFailAction $SMSTSfile

# Write the failed action (This PoSh variable would be written to the CSV file as the failure reason)
Write-Host $SmstFailAction
