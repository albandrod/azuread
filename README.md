# Azure AD | Azure B2B | Graph API

Hello!

Recently I was working on creating synchronization between two platforms, 
The source contains all users and the destination was Azure cloud, 
In Azure cloud B2B account must be created comparing with source, 
Both, the source and destination, use the REST API and a coding tool was PowerShell.

It took me some time to find all needed commands to set this up, 
So I want to share my findings, maybe someone looking for it too :)

Here you can find how to use PowerShell with Graph API for:

1. Connect to the Azure tenant Graph API: 
https://github.com/lightupdifire/azuread/blob/master/Get-AccessToken.ps1

2. Get all tenant Guest users:
https://github.com/lightupdifire/azuread/blob/master/Get-AllGuestUsers.ps1

3. Register/Invite B2B account:
https://github.com/lightupdifire/azuread/blob/master/InviteB2BUser.ps1

4. Send mail to B2B user
https://github.com/lightupdifire/azuread/blob/master/SendMail.ps1


5. Disable B2B account


6. Add B2B account to group


7. Update B2B account


8. Check B2B account invitation status


9. Check if B2B account is disabled


Here I will place all script separately, so you can take parts of it and integrate it in one big if you need it.

For help, please check WIKI: https://github.com/lightupdifire/azuread/wiki

In the future, I plan to integrate it directly with Azure Blob/Table, so any response file or log file will be saved in the Azure cloud too.
