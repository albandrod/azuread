################################################################################################################################################
################################################################################################################################################
# 
# This script receive access token and invite B2B user to Azure AD tenant
# Access Token is valid for 1 hour as a default configuration of Azure AD
# When Access Token received, can operate with Graph  API with other operations like update/disable/create user etc.
# Please Register Web Application in Azure AD and grant permissions, see: https://github.com/lightupdifire/azuread/wiki/Get-AccessToken
# Please grant Application permissions for Invitation, see: https://github.com/lightupdifire/azuread/wiki/InviteB2BUser
#
################################################################################################################################################
################################################################################################################################################
# Make sure that the connection will be setup with TLS 1.2
#
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
#
################################################################################################################################################
################################################################################################################################################
# Setting up Variables Start
#
# Please provide Application (client) ID, Tenant Name and Application secret, see: https://github.com/lightupdifire/azuread/wiki/Get-AccessToken
# 
write-host "You can replace values below in script and remove Read-Host prompt setup" -ForeGroundColor Magenta
#
$clientId = Read-Host -Prompt "Please enter your Application client ID without quotas"
$tenantName = Read-Host -Prompt "Please enter your Tenant ID without quotas"
$clientSecret = Read-Host -Prompt "Please enter your Application Secret key without quotas"
#
# Set Logging
#
$workdir = Get-Location
$date = Get-Date
$logfile = "$workdir\" + "Get-AccessToken_" + $date.day + "-" + $date.month + "-" + $date.year + ".log"
$Transcript = "$workdir\" + "Get-AccessToken_transcript" + $date.day + "-" + $date.month + "-" + $date.year + ".log"
#
# Setting up Variables End
################################################################################################################################################
################################################################################################################################################
# Start Transcript
#
Start-Transcript -Path $Transcript -force
#
################################################################################################################################################
################################################################################################################################################
# Function to get access token start
#
Function Get-AccessToken {
    param(
        [string]$clientID
        ,[string]$clientSecret
    )
$ReqTokenBody = @{
    Grant_Type    = "client_credentials"
    Scope         = "https://graph.microsoft.com/.default"
    client_Id     = $clientID
    Client_Secret = $clientSecret
} 
try {
$TokenResponse = Invoke-RestMethod -Uri "https://login.microsoftonline.com/$TenantName/oauth2/v2.0/token" -Method POST -Body $ReqTokenBody
$AccessToken = $TokenResponse.access_token
# If received access token, then return it to value and stop function
	if ($AccessToken){
		write-host "Access token well received - $date" -Foregroundcolor Green
		$logdata = "Access token well received - $date"
		$logdata | out-file -filepath $logfile -Append
		return $AccessToken
	}
	else 
		{
# If access token not exist, stop function and exit script
		write-host "This is from Get-AccessToken function, access token fail to receive, stopping script" -ForegroundColor Red
		$logdata = "This is from Get-AccessToken function, access token fail to receive, stopping script"
		$logdata | out-file -filepath $logfile -Append
		break
		exit
		}
# Catch error and store in log file
	} catch {
			$ErrorMessage = $_.Exception.Message
			write-host "This is from Get-AccessToken function, Error: $ErrorMessage" -ForegroundColor Red
			$logdata = "This is from Get-AccessToken function, Error: $ErrorMessage"
			$logdata | out-file -filepath $logfile -Append
			}
}
#
# Function to get access token end
################################################################################################################################################
################################################################################################################################################
# Assign value to variable for Access Token
#
$AccessToken = Get-AccessToken -clientid $clientID -clientSecret $clientSecret -ErrorAction Stop
# 
################################################################################################################################################
################################################################################################################################################
# Check if Email format equal real email address format
#
Function EmailRegexCheck(){
    param(
		 [string]$EmailRegexInput
    )
try {
	$EmailRegex = '^([\w-\.]+)@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.)|(([\w-]+\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})(\]?)$'
	$EmailRegexMatch = $EmailRegexInput -match $EmailRegex
		if ($EmailRegexMatch) {
			write-host "Email format is OK for $EmailRegexInput"
			$logdata = "Email format is OK for $EmailRegexInput"
			$logdata | out-file -filepath $logfile -Append
			return $EmailRegexInput
		}
		else {
			$EmailRegexMatch = $false
			write-host "Bad email format for $EmailRegexInput"
			$logdata = "Bad email format for $EmailRegexInput"
			$logdata | out-file -filepath $logfile -Append
			return $EmailRegexMatch
			}
  	} catch {
			$ErrorMessage = $_.Exception.Message
			write-host "This is from EmailRegexCheck function, Error: $ErrorMessage" -ForegroundColor Red
			$logdata = "This is from EmailRegexCheck function, Error: $ErrorMessage"
			$logdata | out-file -filepath $logfile -Append
			}
}
#
################################################################################################################################################
################################################################################################################################################
# Function to Invite B2B user(s)
#
function InviteB2BUser () {
	    param(
		 [string]$DisplayName
		, [string]$UserToInvite
		, [string]$TenantName
		, [string]$AccessToken
)
#
# Setting the Redirect URL as MyApps, it is to where user will be redirected after confirm registration
#
# If you have DisplayName, you can set it for $DisplayName, in this script applied DisplayName to be same as invited user email address
#
$RedirectTo = "https://account.activedirectory.windowsazure.com/applications/default.aspx?tenantId=$TenantName&amp;login_hint=$UserToInvite"
$UserType = "Guest"
$endPoint = "https://graph.microsoft.com/v1.0/invitations"
$Headers = @{Authorization = "Bearer $AccessToken"}
#
# Can set 'SendInvitationMessage = $false' if you don't want to send invitation mail
#
$invitation = @{
        InvitedUserDisplayName = $DisplayName;
        InvitedUserEmailAddress = $UserToInvite;
        InviteRedirectUrl = $RedirectTo;
        SendInvitationMessage = $true;
        InvitedUserType = $UserType;
    }
    $BodyInviteB2BUser = ConvertTo-Json $invitation
try {
#
# Create invitation, please grant Application permissions for Invitation, see: https://github.com/lightupdifire/azuread/wiki/InviteB2BUser
#
$invite = Invoke-RestMethod -Uri $endPoint -Method Post -Headers $Headers -Body $BodyInviteB2BUser -ErrorAction Stop
$invitationstatus = $invite.status
#
		if ($invitationstatus -eq "PendingAcceptance") {
		write-host "This is from InviteB2BUser function, invitation completed to user: $UserToInvite" -Foregroundcolor Green
		$logdata = "This is from InviteB2BUser function, invitation completed to user: $UserToInvite"
		$logdata | out-file -filepath $logfile -Append
		}
	} catch {
			$ErrorMessage = $_.Exception.Message
			write-host "This is from InviteB2BUser function, Error: $ErrorMessage" -ForegroundColor Red
			$logdata = "This is from InviteB2BUser function, Error: $ErrorMessage"
			$logdata | out-file -filepath $logfile -Append
			}
}
#
################################################################################################################################################
################################################################################################################################################
# Please type email address of user you want to invite in prompt
#
write-host "You can replace value below in script and remove Read-Host prompt and add user email address" -ForeGroundColor Magenta
$UserToInvite = Read-Host -Prompt "Please type here email address of the user you want to invite, without quotas"
#
# Checking email format, should be supported email address, this can be removed in general, but to avoid wrong email format, could be handy
#
$UserToInviteCheck = EmailRegexCheck -EmailRegexInput $UserToInvite -ErrorAction Stop
If ($UserToInviteCheck -eq $false){
write-host "Entered email address: $UserToInvite has a bad email format" -ForeGroundColor Red
$logdata = "Entered email address: $UserToInvite has a bad email format"
$logdata | out-file -filepath $logfile -Append
}
else{
# Calling invitation function
InviteB2BUser -AccessToken $AccessToken -UserToInvite $UserToInvite -TenantName $TenantName -DisplayName $UserToInvite -ErrorAction Stop
}
#
################################################################################################################################################
################################################################################################################################################
# Ending script
# 
$date = Get-Date
write-host "Script End: $date" -ForeGroundColor Green
$logdata = "Script End: $date"
$logdata | out-file -filepath $logfile -Append
Stop-Transcript
break
exit
################################################################################################################################################
################################################################################################################################################
