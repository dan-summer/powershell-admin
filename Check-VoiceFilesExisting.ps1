<#
.SYNOPSIS
    Cheking .mp3 files 
.DESCRIPTION
    Checking existence of .mp3 files from two sources and sending mail meassage if one of files of one source is missing
.EXAMPLE
    .\Check-VoiceFilesExisting.ps1
.NOTES
    Search is carried out for the last 4 hours since the script was launched
#>

$path = "D:\FTPDir\tlf-voice"

$hours = New-TimeSpan -hours 8

$period = (Get-Date) - $hours

$files = Get-ChildItem -Recurse -Path $path -Filter *.mp3 | Where-Object {$_.LastWriteTime -gt $period}

$countgci1 = ($files | Where-Object {$_.Name -like "*-????-??-??-??_??.mp3"} | Measure-Object).Count
$countgci2 = ($files | Where-Object {$_.Name -like "????-??-??-??-??-??-*.mp3"} | Measure-Object).Count

if ($countgci1 -eq 0 -or $countgci2 -eq 0)
{
    Send-MailMessage -SmtpServer grmt -to dit@somedomain.ru -from voice@somedomain.ru -subject "Voice files existing" -body "Some voice-files are missing.`n`nAsterisk IRK: $countgci1 `nAsterisk MSK: $countgci2" -Priority High
}
Read-Host "exit"
