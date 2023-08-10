# PSWinEventLogTool

A utility script to export and compress Windows event logs for further analysis.

This version has been loosely tested on modern versions of Windows and Windows Server. Modern Windows systems with PowerShell should be able to run it.

Please note that this script requires Administrative privileges due to the fact that this is required to export some of these logs. There is an accompanying launcher batch/command script that will run the PowerShell script with a temporary execution policy bypass and Administrative privileges (provided of course Admin credentials can be provided to run it). Also please note that when using the batch/command script, this must be run from a local drive and not a network UNC path location or mapped network drive.

This script helps with granular exporting of specified Windows event logs. It's an expansion on an older script I wrote around 2012 or so and over the years I have modified it here and there. I'm releasing the current version in PowerShell which leverages the Windows built-in wevtutil utility to export the desired log selection(s).

If you sometimes find yourself in a situation where you need to grab a event logs from a machine and get them off of the machine quickly to analyze, this script is your friend. It will grab the desired event log(s) and then compress the result(s). If you've ever worked with these event logs, you probably know that uncompressed they can be quite large.

Exports can also be done based on a specified time frame - minutes, hours, days, etc are supported. So in a scenario where you had a situation maybe an hour ago with a system crashing, you can export the last hour or two only. This keeps the results slim, easier to transfer, and quicker to process/assess.


## Automated Usage

By request, experimental automated support is now available. Please see below.

Example Usage:

    .\PSWinEventLogTool.ps1 -param_evt_log 1 -param_time_unit 1 -param_time_how_much 15

The example above should bypass the menus and return a zip containing the Application Log exported for the last 15 minutes previous to the execution time.


### Parameters:
param_evt_log - Selects which event log, from the available options:
1. Application Log
2. System Log
3. Security Log
4. All Logs

param_time_unit - Selects the unit of time we are exporting in, from the available options:
1. Minutes
2. Hours
3. Days
4. Weeks
5. All Time

param_time_how_much - How much of the selected time unit are we exporting (if applicable - not required if param_time_unit is set to 5):
- (Input Time Quantity)


## Development
There is a development branch available if you're feeling adventurous.

If you see something I have missed, something I should do differently, something I could do better, or maybe there is something you think could be added, please let me know.


## License
This software is being released under the GNU LESSER GENERAL PUBLIC LICENSE. Please see the license document in the repository for more information.


## Disclaimer
This script is probably unstable and full of bugs. Like everything else on the internet, run at your own risk.