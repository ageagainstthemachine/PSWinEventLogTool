#PowerShell Windows Event Log Export And Compression Tool Script by Julian McConnell
#https://julianmcconnell.com
#Version 20220827a


#Does require admin privileges due to the security log option
#Requires -RunAsAdministrator

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
    If ($selectionmenuselection -eq '1')
    {
        [String]$selectedlog = 'Application'
        TimeFrameSelectionMenu
    }
    
    ElseIf ($selectionmenuselection -eq '2')
    {
        $selectedlog = 'System'
        TimeFrameSelectionMenu
    }
    
    ElseIf ($selectionmenuselection -eq '3')
    {
        $selectedlog = 'Security'
        TimeFrameSelectionMenu
    }
    
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

function TimeFrameSelectionMenu 
{
    #Basic menu for timeframe selection
    Clear-Host
    Write-Host 'What is the desired timeframe for this export?'
    Write-Host 'Press 1 For Minutes'
    Write-Host 'Press 2 For Hours'
    Write-Host 'Press 3 For Days'
    Write-Host 'Press 4 For Weeks'
    Write-Host 'Press 5 For All Time'
    Write-Host 'Press 6 To Exit Script'
    
    #User input prompt for the timeframe selection
    [int]$timeframemenuselection = Read-Host 'Please type a selection...'
    
    #Selections
    If ($timeframemenuselection -eq '1')
    {
        [String]$unitoftime = 'Minutes'
        SpecificTimeSelection
    }
    
    ElseIf ($timeframemenuselection -eq '2')
    {
        [String]$unitoftime = 'Hours'
        SpecificTimeSelection
    }
    
    ElseIf ($timeframemenuselection -eq '3')
    {
        [String]$unitoftime = 'Days'
        SpecificTimeSelection
    }
    
    ElseIf ($timeframemenuselection -eq '4')
    {
        [String]$unitoftime = 'Weeks'
        SpecificTimeSelection
    }

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

    else 
    {
        #Proceed to time selection menu
        TimeFrameSelectionMenu
    }
}


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

    #User input prompt for the timeframe selection
    [int]$howmuchtime = Read-Host 'Please enter amount...'
    
    if ($null -eq $howmuchtime)
    {
        #Warn user that there was no value entered
        Write-Host 'No value entered!'

        #Pause
        Pause

        #Return to menu
        SpecificTimeSelection
    }
    else
    {
        CalculateTimeDiff
    }
    
}

function CalculateTimeDiff
{
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

function ExportAllLogsForAllTime
{
    #Export all logs for all time
    wevtutil epl Application "${PSScriptRoot}\Application_All.evtx"
    wevtutil epl System "${PSScriptRoot}\System_All.evtx"
    wevtutil epl Security "${PSScriptRoot}\Security_All.evtx"

    #Proceed to check if we're ready to compress
    ReadyToZip
}

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
    wevtutil epl Application /q:$applicationquery $applicationlogfilename
    wevtutil epl System /q:$systemquery $systemlogfilename
    wevtutil epl Security /q:$securityquery $securitylogfilename

    #Proceed to check if we're ready to compress
    ReadyToZip
}

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

function ExportSpecificLogForSpecificTime
{
    #Export specific log for a specific amount of time
    If ($selectionmenuselection -eq '1' -and $timeframemenuselection -ne '5')
    {
        #Export the application log for the specific time
        [String]$applicationlogfilename = "${PSScriptRoot}\" + "Application_Last_" + [String]$howmuchtime + "_" + $unitoftime + ".evtx"
        [String]$applicationquery = "*[System[TimeCreated[timediff(@SystemTime) <=" + [String]$totaltime + "]]]"
        wevtutil epl Application /q:$applicationquery $applicationlogfilename
    }

    ElseIf ($selectionmenuselection -eq '2' -and $timeframemenuselection -ne '5')
    {
        #Export the system log for the specific amount of time
        [String]$systemlogfilename = "${PSScriptRoot}\" + "System_Last_" + [String]$howmuchtime + "_" + $unitoftime + ".evtx"
        [String]$systemquery = "*[System[TimeCreated[timediff(@SystemTime) <=" + [String]$totaltime + "]]]"
        wevtutil epl System /q:$systemquery $systemlogfilename
    }
    
    ElseIf ($selectionmenuselection -eq '2' -and $timeframemenuselection -ne '5')
    {
        #Export the security log for the specific amount of time
        [String]$securitylogfilename = "${PSScriptRoot}\" + "Security_Last_" + [String]$howmuchtime + "_" + $unitoftime + ".evtx"
        [String]$securityquery = "*[System[TimeCreated[timediff(@SystemTime) <=" + [String]$totaltime + "]]]"
        wevtutil epl Security /q:$securityquery $securitylogfilename
    }

    #Proceed to check if we're ready to compress
    ReadyToZip
}

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

function CompressLogs
{
    #Time to compress what we exported
    Write-Host 'Compressing log files...'
    Compress-Archive -Path "${PSScriptRoot}\*.evtx" -DestinationPath "${PSScriptRoot}\Windows_Event_Log_Export_$timestampformat.zip"  
    Remove-Item "${PSScriptRoot}\*.evtx" -Force

    #Quit when finished
    quitscript
}

function quitscript
{
    #Cleanup
    #Clear-Host
    Write-Host 'Complete!'
    Exit
}

#Call the first menu
EventLogSelectionMenu