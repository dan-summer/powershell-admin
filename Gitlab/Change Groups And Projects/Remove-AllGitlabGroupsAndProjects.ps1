<#
.SYNOPSIS
    Remove from all groups and projects
.DESCRIPTION
    Removing user from all gitlab groups and subprojects
.EXAMPLE
    .\Remove-AllGitlabGroupsAndProjects.ps1
.NOTES
    Removing via Gitlab API and user private gitlab token
#>

$privatGitlabToken = '************'

$protocols = [System.Net.SecurityProtocolType]'Ssl3,Tls,Tls11,Tls12'
[System.Net.ServicePointManager]::SecurityProtocol = $protocols

$groupsPerPages = @()

$pages = 1000
$userId = 369
$accessLevel = 20
$body = 'user_id=' + $userId + '&access_level=' + $accessLevel
$statusCode = 404

$user = Invoke-RestMethod -Headers @{'PRIVATE-TOKEN' = $privatGitlabToken} -uri "https://gitlab.somedomain.ru/api/v4/users/$($userId)" -ContentType 'application/json' -method Get

for ($pageNumber = 1; $pageNumber -lt $pages; $pageNumber++) 
{
   $restRequest = Invoke-RestMethod -Headers @{'PRIVATE-TOKEN' = $privatGitlabToken} -uri "https://gitlab.somedomain.ru/api/v4/groups?page=$pageNumber&per_page=$pages" -ContentType 'application/json' -method Get 
   $groupsPerPages += $restRequest
}

$groupsWithoutParentId = $groupsPerPages | where {$_.parent_id -eq $null} | select name, id, path, web_url | sort id -Descending

foreach ($group in $groupsWithoutParentId)
{  
    
    try 
    {
        Invoke-RestMethod -Headers @{'PRIVATE-TOKEN' = $privatGitlabToken} -uri "https://gitlab.somedomain.ru/api/v4/groups/$($group.id)/members/$($userId)" -method Delete
        Write-Host "$($user.username) deleted from group: $($group.web_url)" -ForegroundColor Green
    }
    catch 
    {
        if ($_.Exception.Response.StatusCode.value__ -eq $statusCode) 
        {
            Write-Host `n"$($user.username) is not a member of a group: $($group.web_url)" -ForegroundColor Red   
        }
    }
}