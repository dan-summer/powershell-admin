# powershell-admin
Powershell scripts written by me to help enterprise system administrators
For more detailed description look at .DESCRIPTION or .NOTES in the begining of script
---

## Gitlab
### ./Gitlab/Change Groups And Projects/Add-AllGitlabGroupsAndProjects.ps1
Adding user to all gitlab groups and subprojects
### ./Gitlab/Change Groups And Projects/Remove-AllGitlabGroupsAndProjects.ps1.ps1
Removing user from all gitlab groups and subprojects
### ./Gitlab/Gitlab Users/Get-ActiveGitlabUsers.ps1
Getting active gitlab users in the last 6 months
## Active Directory
### ./Get-ActiveADUsers.ps1
Listing active users from ActiveDirectory to CSV file
### ./Get-InactiveADUsers.ps1
Listing inactive users from ActiveDirectory to CSV file
### ./Get-InactiveADComputers.ps1
Listing inactive not disabled AD computers from ActiveDirectory to CSV file
### ./Get-WinInstalledDate.ps1
Getting date of Windows instalation
## Exchange
### ./Get-InactiveMailboxes.ps1
Listing inactive exchange mailboxes to CSV file
### ./Grant-MailboxAccess.ps1
Granting mailbox full access and send as permissions
### ./Get-MailboxQuotas2010.ps1
Checking exchange2010 mailboxes storage qoutas
### ./Get-MailboxQuotas2016.ps1
Checking exchange2016 mailboxes storage qoutas
## Others
### ./Change-LocAdminPass.ps1
Changing local administrator passwords on computers outside the domain
### ./Check-VoiceFilesExisting.ps1
Checking existence of .mp3 files from two sources and sending mail meassage if one of files of one source is missing
### ./Generate-Files.ps1
Generating .txt files of 1MB size
### ./Parse-Logs.ps1
Parsing logs by checking the presence of the words and counting
### ./Set-LogonBackground.ps1
Setting windows logon screen background picture
