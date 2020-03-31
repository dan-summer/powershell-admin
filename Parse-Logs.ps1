<#
.SYNOPSIS
    Logs Parsing
.DESCRIPTION
    Parsing logs by checking the presence of the words and counting
.EXAMPLE
    .\Parse-Logs.ps1
.NOTES
    Output statistics to path C:\TEMP\LogsParser.txt
#>

cd C:\exch_logs

$gci = Get-ChildItem -path 'C:\exch_logs'

New-Item -ItemType file  C:\TEMP\LogsParser.txt -ErrorAction SilentlyContinue

$Counter=0

foreach ($file in $gci)
{
    $Counter++
    
    #Progress bar
	Write-Progress -Activity "[Processing $Counter of $($gci.Count)]" -Status "Querying $file" -PercentComplete (($counter/$gci.Count)*100) -CurrentOperation "$([math]::Round(($counter/$gci.Count)*100))% complete"
	
	$owa=    Select-String -path c:\exch_logs\$file -Pattern "owa"
	
	$office= Select-String -path c:\exch_logs\$file -Pattern "office"
	
	$prtg=   Select-String -path c:\exch_logs\$file -Pattern "PRTG"
	
	$mobile= Select-String -path c:\exch_logs\$file -Pattern "Microsoft-Server-ActiveSync"
	
	$total=  Get-Content $file | Measure-Object -line | Select-Object -ExpandProperty lines

	$others=$total-$mobile.count-$prtg.count-$office.count-$owa.count

	$obj=New-Object psobject
	
	$obj | Add-Member -MemberType NoteProperty -Name "CreationTime" -Value $file.CreationTime.ToString("yyyy.MM.dd")
	
	$obj | Add-Member -MemberType NoteProperty -Name "OWA"          -Value $owa.count
	
	$obj | Add-Member -MemberType NoteProperty -Name "Office"   	-Value $office.count

	$obj | Add-Member -MemberType NoteProperty -Name "PRTG"     	-Value $prtg.count
	
	$obj | Add-Member -MemberType NoteProperty -Name "Mobile"   	-Value $mobile.count

	$obj | Add-Member -MemberType NoteProperty -Name "Total"    	-Value $total

	$obj | Add-Member -MemberType NoteProperty -Name "Other"    	-Value $others

	$obj | ft -AutoSize | Out-File -FilePath C:\TEMP\LogsParser.txt -Append -NoClobber 
}
cls
Read-Host "Done, press Enter to exit"