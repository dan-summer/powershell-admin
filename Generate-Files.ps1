<#
.SYNOPSIS
    Files Generator
.DESCRIPTION
    Generating .txt files of 1MB size
.EXAMPLE
    .\Generate-Files.ps1
.NOTES
    Generating files to path D:\Files\...
#>

$array = New-Object -TypeName Byte[] -ArgumentList 1Mb

$obj = New-Object -TypeName System.Random

$obj.NextBytes($array)

for ($i = 1; $i -le 1024; $i++) 

{Set-Content -Path D:\Files\File$i.txt -Value $array -Encoding Byte}