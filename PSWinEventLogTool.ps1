#PowerShell Windows Event Log Export And Compression Tool Script by Julian McConnell
#https://julianmcconnell.com
#Version 20230809a


#Does require admin privileges due to the security log option
#Requires -RunAsAdministrator

#Experimental parameters support (by request)
#$param_evt_log = which event log (follows the integers in the selection menu)
#$param_time_unit = which time unit (follows the integers in the selection menu)
#$param_time_how_much = how much of the specific time unit (except if all time was selected for $param_time_unit)
param ([int] $param_evt_log, $param_time_unit, $param_time_how_much)

#Date and time setup
[String]$day = (get-date).day
[String]$month = (get-date).month
[String]$year = (get-date).year
[String]$hour = (get-date).hour
[String]$minute = (get-date).minute
[String]$second = (get-date).second
[String]$ms = (get-date).millisecond

#Let's make a timestamp format
[String]$timestampformat = $year + $month + $day + '-' + $hour + $minute + $second + $ms

#Event log selection menu
function EventLogSelectionMenu 
{
    #Basic menu for selections
    Clear-Host
    Write-Host 'Which event log would you like to export and compress?'
    Write-Host 'Press 1 For Application Log'
    Write-Host 'Press 2 For System Log'
    Write-Host 'Press 3 For Security Log'
    Write-Host 'Press 4 For All Logs'
    Write-Host 'Press 5 To Exit Script'
    
    #User input prompt for the selection
    [int]$selectionmenuselection = Read-Host 'Please type a selection...'
    
    #Selections
    #1 = Application
    If ($selectionmenuselection -eq '1')
    {
        [String]$selectedlog = 'Application'
        TimeFrameSelectionMenu
    }
    #2 = System
    ElseIf ($selectionmenuselection -eq '2')
    {
        $selectedlog = 'System'
        TimeFrameSelectionMenu
    }
    #3 = Security
    ElseIf ($selectionmenuselection -eq '3')
    {
        $selectedlog = 'Security'
        TimeFrameSelectionMenu
    }
    #4 = All
    ElseIf ($selectionmenuselection -eq '4')
    {
        $selectedlog = 'All'
        TimeFrameSelectionMenu
    }
    #If the selection was 5, let's quit
    ElseIf ($selectionmenuselection -eq '5')
    {
        exit
    }
    #Catch-all for if there's an invalid choice entered (return to top of menu)
    else 
    {
        #Warn user about invalid entry
        Write-Host 'Invalid entry. Please try again!'

        #Pause
        Pause

        #Return to previous menu to try again
        EventLogSelectionMenu
    }
}

#Time unit selection menu
function TimeFrameSelectionMenu 
{
    #Basic menu for timeframe selection
    Clear-Host
    Write-Host 'What is the desired timeframe/unit for this export?'
    Write-Host 'Press 1 For Minutes'
    Write-Host 'Press 2 For Hours'
    Write-Host 'Press 3 For Days'
    Write-Host 'Press 4 For Weeks'
    Write-Host 'Press 5 For All Time'
    Write-Host 'Press 6 To Exit Script'
    
    #User input prompt for the timeframe selection
    [int]$timeframemenuselection = Read-Host 'Please type a selection...'
    
    #Selections
    #1 = Minutes
    If ($timeframemenuselection -eq '1')
    {
        [String]$unitoftime = 'Minutes'
        SpecificTimeSelection
    }
    #2 = Hours
    ElseIf ($timeframemenuselection -eq '2')
    {
        [String]$unitoftime = 'Hours'
        SpecificTimeSelection
    }
    #3 = Days
    ElseIf ($timeframemenuselection -eq '3')
    {
        [String]$unitoftime = 'Days'
        SpecificTimeSelection
    }
    #4 = Weeks
    ElseIf ($timeframemenuselection -eq '4')
    {
        [String]$unitoftime = 'Weeks'
        SpecificTimeSelection
    }
    #5 = All Time
    ElseIf ($timeframemenuselection -eq '5')
    {
        #
        [String]$unitoftime = 'All Time'
        CheckOptionsToProceed
    }
    #If the selection was 6, let's quit
    ElseIf ($timeframemenuselection -eq '6')
    {
        exit
    }
    #Otherwise, proceed
    else 
    {
        #Proceed to time selection menu
        TimeFrameSelectionMenu
    }
}

#Specific time input menu
function SpecificTimeSelection
{
    #Basic input for specific time selection
    Clear-Host
    Write-Host 'How much of the specific time unit chosen would you like to export?'
    
    #Previously-selected options drive the write-host text
    If ($timeframemenuselection -eq '1')
    {
        Write-Host '(In Minutes)'
    }

    ElseIf ($timeframemenuselection -eq '2')
    {
        Write-Host '(In Hours)'
    }
    
    ElseIf ($timeframemenuselection -eq '3')
    {
        Write-Host '(In Days)'
    }
    
    ElseIf ($timeframemenuselection -eq '4')
    {
        Write-Host '(In Weeks)'
    }

    #User input prompt for the amount (how much time)
    [int]$howmuchtime = Read-Host 'Please enter amount...'
    
    #If nothing was entered, go down this path
    if ($null -eq $howmuchtime)
    {
        #Warn user that there was no value entered
        Write-Host 'No value entered!'

        #Pause
        Pause

        #Return to menu
        SpecificTimeSelection
    }
    #Otherwise, proceed
    else
    {
        #Move along to calculate the time differential
        CalculateTimeDiff
    }
    
}

#Calculate the time differential
function CalculateTimeDiff
{
    #Driven from previous timeframe menu selections in TimeFrameSelectionMenu
    If ($timeframemenuselection -eq '1')
    {
        #Calculate total time differential and then proceed to check options
        [Int32]$totaltime = 60000 * $howmuchtime
        CheckOptionsToProceed
    }
    
    ElseIf ($timeframemenuselection -eq '2')
    {
        #Calculate total time differential and then proceed to check options
        [Int32]$totaltime = 3600000 * $howmuchtime
        CheckOptionsToProceed
    }
    
    ElseIf ($timeframemenuselection -eq '3')
    {
        #Calculate total time differential and then proceed to check options
        [Int32]$totaltime = 86400000 * $howmuchtime
        CheckOptionsToProceed
    }
    
    ElseIf ($timeframemenuselection -eq '4')
    {
        #Calculate total time differential and then proceed to check options
        [Int32]$totaltime = 604800000 * $howmuchtime
        CheckOptionsToProceed
    }
    else 
    {
        #Just in case!
        CheckOptionsToProceed
    }
}

function CheckOptionsToProceed
{
    #We need to check what we're doing to go forward

    #If selection is all logs and all time
    If ($selectionmenuselection -eq '4' -and $timeframemenuselection -eq '5')
    {
        #Proceed
        ExportAllLogsForAllTime
    }
    
    #If selection is all logs and specific time
    ElseIf ($selectionmenuselection -eq '4' -and $timeframemenuselection -ne '5')
    {
        #Proceed
        ExportAllLogsForSpecificTime
    }

    #If selection is specific log and all time
    ElseIf ($selectionmenuselection -ne '4' -and $timeframemenuselection -eq '5')
    {
        #Proceed
        ExportSpecificLogForAllTime
    }
    
    #If selection is specific log and specific time
    ElseIf ($selectionmenuselection -ne '4' -and $timeframemenuselection -ne '5')
    {
        #Proceed
        ExportSpecificLogForSpecificTime
    }


}

#Export all logs for all time
function ExportAllLogsForAllTime
{
    #Export all logs for all time
    wevtutil epl Application "${PSScriptRoot}\Application_All.evtx"
    wevtutil epl System "${PSScriptRoot}\System_All.evtx"
    wevtutil epl Security "${PSScriptRoot}\Security_All.evtx"

    #Proceed to check if we're ready to compress
    ReadyToZip
}

#Export all logs for a specific timeframe
function ExportAllLogsForSpecificTime
{
    #Export all logs for a specific amount of time

    #Setup file names for the logs
    [String]$applicationlogfilename = "${PSScriptRoot}\" + "Application_Last_" + [String]$howmuchtime + "_" + $unitoftime + ".evtx"
    [String]$systemlogfilename = "${PSScriptRoot}\" + "System_Last_" + [String]$howmuchtime + "_" + $unitoftime + ".evtx"
    [String]$securitylogfilename = "${PSScriptRoot}\" + "Security_Last_" + [String]$howmuchtime + "_" + $unitoftime + ".evtx"
    
    #Setup queries for the logs
    [String]$applicationquery = "*[System[TimeCreated[timediff(@SystemTime) <=" + [String]$totaltime + "]]]"
    [String]$systemquery = "*[System[TimeCreated[timediff(@SystemTime) <=" + [String]$totaltime + "]]]"
    [String]$securityquery = "*[System[TimeCreated[timediff(@SystemTime) <=" + [String]$totaltime + "]]]"

    #Export the logs with queries and filenames
    wevtutil epl Application /q:$applicationquery "$applicationlogfilename"
    wevtutil epl System /q:$systemquery "$systemlogfilename"
    wevtutil epl Security /q:$securityquery "$securitylogfilename"

    #Proceed to check if we're ready to compress
    ReadyToZip
}

#Export specific logs for all time
function ExportSpecificLogForAllTime
{
    #Export the specific log for all time
    If ($selectionmenuselection -eq '1')
    {
        #Export the application log
        wevtutil epl Application "${PSScriptRoot}\Application_All.evtx"
    }

    ElseIf ($selectionmenuselection -eq '2')
    {
        #Export the system log
        wevtutil epl System "${PSScriptRoot}\System_All.evtx"
    }
    
    ElseIf ($selectionmenuselection -eq '2')
    {
        #Export the security log
        wevtutil epl Security "${PSScriptRoot}\Security_All.evtx"
    }

    #Proceed to check if we're ready to compress
    ReadyToZip
}

#Export specific logs for specific time
function ExportSpecificLogForSpecificTime
{
    #Export specific log for a specific amount of time
    If ($selectionmenuselection -eq '1' -and $timeframemenuselection -ne '5')
    {
        #Export the application log for the specific time
        [String]$applicationlogfilename = "${PSScriptRoot}\" + "Application_Last_" + [String]$howmuchtime + "_" + $unitoftime + ".evtx"
        [String]$applicationquery = "*[System[TimeCreated[timediff(@SystemTime) <=" + [String]$totaltime + "]]]"
        wevtutil epl Application /q:$applicationquery "$applicationlogfilename"
    }

    ElseIf ($selectionmenuselection -eq '2' -and $timeframemenuselection -ne '5')
    {
        #Export the system log for the specific amount of time
        [String]$systemlogfilename = "${PSScriptRoot}\" + "System_Last_" + [String]$howmuchtime + "_" + $unitoftime + ".evtx"
        [String]$systemquery = "*[System[TimeCreated[timediff(@SystemTime) <=" + [String]$totaltime + "]]]"
        wevtutil epl System /q:$systemquery "$systemlogfilename"
    }
    
    ElseIf ($selectionmenuselection -eq '2' -and $timeframemenuselection -ne '5')
    {
        #Export the security log for the specific amount of time
        [String]$securitylogfilename = "${PSScriptRoot}\" + "Security_Last_" + [String]$howmuchtime + "_" + $unitoftime + ".evtx"
        [String]$securityquery = "*[System[TimeCreated[timediff(@SystemTime) <=" + [String]$totaltime + "]]]"
        wevtutil epl Security /q:$securityquery "$securitylogfilename"
    }

    #Proceed to check if we're ready to compress
    ReadyToZip
}

#Check if we are ready to zip the files
function ReadyToZip
{
    #Check if the process is running
    $check=Get-Process wevtutil -ErrorAction SilentlyContinue
    if ($null -eq $check) 
    {
        #If not running, proceed to compress logs
        CompressLogs
    }
    else 
    {
        #If still running, wait and then go back again
        Start-Sleep -s 2
        ReadyToZip
    }
}

#Compress the logs
function CompressLogs
{
    #Time to compress what we exported
    Write-Host 'Compressing log files...'
    Compress-Archive -Path "${PSScriptRoot}\*.evtx" -DestinationPath "${PSScriptRoot}\Windows_Event_Log_Export_$timestampformat.zip"  
    Remove-Item "${PSScriptRoot}\*.evtx" -Force

    #Quit when finished
    quitscript
}

#Quit the script
function quitscript
{
    #Cleanup
    #Clear-Host
    Write-Host 'Complete!'
    Exit
}


#bypass menus if a proper combo of parameters were passed along
#if $param_evt_log was greater than or equal to 1 or less than or equal to 4, and $param_time_unit was greater than or equal to 1 or less than or equal to 4, and $param_time_how_much was greater than or equal to 1
If ((($param_evt_log -ge '1') -and ($param_evt_log -le '4')) -and (($param_time_unit -ge '1') -and ($param_time_unit -le '4')) -and ($param_time_how_much -ge '1'))
{
    #set three things via this path - the log selection, the time unit, and how much time to export
    #set $selectionmenuselection from $param_evt_log
    $selectionmenuselection = $param_evt_log
    #set $timeframemenuselection from $param_time_unit
    $timeframemenuselection = $param_time_unit
    #set $howmuchtime from $param_time_how_much
    $howmuchtime = $param_time_how_much

    #skip ahead with the new stuff, just as we would via a menu walk-through
    CalculateTimeDiff
}
#elseif $param_evt_log is greater than or equal to 1, and less than or equal to 4, and $param_time_unit is equal to 5 (all events in the selected log/all time equivalent)
ElseIf ((($param_evt_log -ge '1') -and ($param_evt_log -le '4')) -and ($param_time_unit -eq '5'))
{
    #set two things via this path - the log selection and the time unit, and how much time to export
    #set $selectionmenuselection from $param_evt_log
    $selectionmenuselection = $param_evt_log
    #set $timeframemenuselection from $param_time_unit
    $timeframemenuselection = $param_time_unit
    
    #skip ahead with the new stuff, just as we would via a menu walk-through
    CheckOptionsToProceed
}

#Call the first menu
EventLogSelectionMenu