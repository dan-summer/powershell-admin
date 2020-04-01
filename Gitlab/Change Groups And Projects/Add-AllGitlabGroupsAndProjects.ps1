<#
.SYNOPSIS
    Add to all groups and projects
.DESCRIPTION
    Adding user to all gitlab groups and subprojects
.EXAMPLE
    .\Add-AllGitlabGroupsAndProjects.ps1
.NOTES
    Adding via Gitlab API and user private gitlab token
#>

$privatGitlabToken = '************'

$protocols = [System.Net.SecurityProtocolType]'Ssl3,Tls,Tls11,Tls12'
[System.Net.ServicePointManager]::SecurityProtocol = $protocols

$groupsPerPages = @()

$pages = 1000
$userId = 703
$accessLevel = 30
$body = 'user_id=' + $userId + '&access_level=' + $accessLevel

$user = Invoke-RestMethod -Headers @{'PRIVATE-TOKEN' = $privatGitlabToken} -uri "https://gitlab.somedomain.ru/api/v4/users/$($userId)" -ContentType 'application/json' -method Get

for ($pageNumber = 1; $pageNumber -lt $pages; $pageNumber++) 
{
   $restRequest = Invoke-RestMethod -Headers @{'PRIVATE-TOKEN' = $privatGitlabToken} -uri "https://gitlab.somedomain.ru/api/v4/groups?page=$pageNumber&per_page=$pages" -ContentType 'application/json' -method Get 
   $groupsPerPages += $restRequest
}

$groupsWithoutParentId = $groupsPerPages | where {$_.parent_id -eq $null} | select name, id, path, web_url | sort id -Descending

foreach ($group in $groupsWithoutParentId)
{  
    
   Invoke-RestMethod -Headers @{'PRIVATE-TOKEN' = $privatGitlabToken} -Body $body -uri "https://gitlab.somedomain.ru/api/v4/groups/$($group.id)/members" -method Post | Out-Null
   Write-Host "$($user.username) added to group: $($group.web_url)" -ForegroundColor Green
    
}