<#
.SYNOPSIS
    Get active users
.DESCRIPTION
    Getting active gitlab users in the last 6 months
.EXAMPLE
    .\Get-ActiveGitlabUsers.ps1
.NOTES
    Output users to path C:\GitlabUsers\lastActivityGitlabUsers.csv
#>

$privatGitlabToken = '*******************'

$protocols = [System.Net.SecurityProtocolType]'Ssl3,Tls,Tls11,Tls12'
[System.Net.ServicePointManager]::SecurityProtocol = $protocols

$pages = 100
$usersPerPages = @()
$activeUsers=@()
$date = $(Get-Date).AddMonths(-6).ToString("yyyy-MM-dd")

for ($pageNumber = 1; $pageNumber -lt $pages; $pageNumber++) 
{
   $restRequest = Invoke-RestMethod -Headers @{'PRIVATE-TOKEN' = $privatGitlabToken} -uri "https://gitlab.somedomain.ru/api/v4/users?active=true&page=$pageNumber&per_page=100" -ContentType 'application/json' -method Get
   $usersPerPages += $restRequest
}

foreach ($user in $usersPerPages) 
{
   Get-ADUser $user.username | Where-Object {$_.Enabled -eq $false} # checking disabled AD users
   
   $object = New-Object psObject
   $object | Add-Member -MemberType NoteProperty -Name 'username' -Value $user.username
   $object | Add-Member -MemberType NoteProperty -Name 'created_at' -Value $($user.created_at -replace ".{19}$")
   if ($user.last_activity_on -eq $null) 
   {
      $object | Add-Member -MemberType NoteProperty -Name 'last_activity' -Value 'Never'
   }
   else 
   {
      $object | Add-Member -MemberType NoteProperty -Name 'last_activity' -Value $user.last_activity_on
   }
   
   $activeUsers += $object
}

$activeUsers | Where-Object {$_.last_activity -eq 'Never' -or $_.last_activity -lt $date} | Export-Csv C:\GitlabUsers\lastActivityGitlabUsers.csv -Delimiter ';' -NoTypeInformation -Encoding UTF8
$activeUsers=''