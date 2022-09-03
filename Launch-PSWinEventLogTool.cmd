echo off
rem PowerShell Windows Event Log Export And Compression Tool Script Launcher
rem https://julianmcconnell.com
rem Version 20220827a

rem Please note this file must be run from a local drive, not a UNC path or network drive.

rem Credit for auto-elevation goes to: https://gist.github.com/Flayed/cafed37bbdc4fb82081d98d87721fd1b#file-launchasadmin-cmd

rem Credit for checking if the script is being run from a UNC path or network drive goes to: https://stackoverflow.com/questions/57703876/windows-10-how-can-i-determine-whether-a-batch-file-is-being-run-from-network-m

rem Check if we're running this from a UNC path (network share) or mapped network drive
if "%~d0" == "\\" (
    echo Batch file was started from a UNC path - "%~dp0". Please move to a local directory! This script will now exit.
    pause
    goto :EOF
)
%SystemRoot%\System32\net.exe use | %SystemRoot%\System32\findstr.exe /I /L /C:" %~d0 " >nul
if not errorlevel 1 (
    echo Batch file was started from network drive %~d0. Please move to a local directory! This script will now exit.
    pause
    goto :EOF
)
echo Running batch file from local drive %~d0. Continuing...

rem Attempt to elevate if not elevated already
:-------------------------------------
REM  --> Check for permissions
    IF "%PROCESSOR_ARCHITECTURE%" EQU "amd64" (
>nul 2>&1 "%SYSTEMROOT%\SysWOW64\cacls.exe" "%SYSTEMROOT%\SysWOW64\config\system"
) ELSE (
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
)

REM --> If error flag set, we do not have admin
if '%errorlevel%' NEQ '0' (
    echo Requesting administrative privileges...
    goto UACPrompt
) else ( goto gotAdmin )

:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    set params= %*
    echo UAC.ShellExecute "cmd.exe", "/c ""%~s0"" %params:"=""%", "", "runas", 1 >> "%temp%\getadmin.vbs"

    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /B

:gotAdmin
    pushd "%CD%"
    CD /D "%~dp0"
:-------------------------------------- 
rem Continue...

echo Launching PowerShell Windows Event Log Export And Compression Tool Script
PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& './PSWinEventLogTool.ps1'";
pause
