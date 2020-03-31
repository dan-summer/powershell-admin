<#
.SYNOPSIS
    Set Logon Background
.DESCRIPTION
    Setting windows logon screen background picture
.EXAMPLE
    .\Set-LogonBackground.ps1
.NOTES
    Setting Logon Background by changing registry key
#>

$regpath=Get-ItemProperty -path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI\Background\"

$filepath="C:\Windows\system32\oobe\info\backgrounds\backgroundDefault.jpg"

$windirpath="C:\Windows\system32\oobe\info\backgrounds\"

$tpathwin=Test-Path $filepath

$AddPCName = Read-Host "Enter computer name"
$ArrayPC = $addPCName -split ", "

$NotOnlinePC=@()

foreach ($computer in $ArrayPC) 
{
    if (Test-connection -Quiet -Delay 1 -Count 2 -ComputerName $computer -ErrorAction silentlycontinue)
    {
        #checking the registry
        if ($regpath.OEMBackground -eq 1)
        {
            Write-Host "The registry value already exists..."
            Read-Host "Press Enter to continue"
        }
        else 
        {
        New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI\Background\" -Name "OEMBackground" -Value 1
        }
        #checking the file
        if ($tpathwin -eq "true")
        {
            Write-Host "The backgroundDefault file.jpg already exists..."
            Read-Host "Press Enter to continue"
        }  
        else
        {
        New-Item -path $windirpath -type directory
        Copy-Item -Path \\ins.ru\NETLOGON\TestLogonBackground\backgroundDefault.jpg -Destination $windirpath
        Read-Host "Press Enter to continue"
        }
    }
    
    else 
    {
        $NotOnlinePC+=$computer
    }
}    
Write-Host "The following computers are offline or the name is incorrect: $NotOnlinePC " -ForegroundColor yellow
Read-Host "Press Enter to continue"