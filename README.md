# azuread

Hello!

Recently I was working on creating synchronization between two platforms, 
The source contains all users and the destination was Azure cloud, 
In Azure cloud B2B account must be created coparing with source, 
Both, the source and destination, use the REST API and a coding tool was PowerShell.

It took me some time to find all needed commands to set this up, 
So I want to share my findings, maybe someone looking for it too :)

Here you can find how to use PowerShell with Graph API for:

1. Connect to the Azure tenant Graph API
2. Get all tenant Guest users
3. Register/Invite B2B account
4. Send mail to B2B user
5. Disable B2B account
6. Add B2B account to group(s)
7. Update B2B account
8. Check B2B account invitation status
9. Check if B2B account is disabled

Here I will place all script separately, so you can take parts of it and integrate it in one big if you need it.

In future I plan to integrate it directly with Azure Blob/Table, so any response file or log file will be saved in Azure cloud too.
