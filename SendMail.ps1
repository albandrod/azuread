################################################################################################################################################
################################################################################################################################################
# 
# This script receive access token and send mail message
# Access Token is valid for 1 hour as a default configuration of Azure AD
# When Access Token received, can operate with Graph  API with other operations like update/disable/create user etc.
# Please Register Web Application in Azure AD and grant permissions, see: https://github.com/lightupdifire/azuread/wiki/Get-AccessToken
# Please grant application Mail Send rights, see: https://github.com/lightupdifire/azuread/wiki/SendMail
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
# Please provide Application (client) ID, Tenant Name and application secret and replace for below before run script, see: https://github.com/lightupdifire/azuread/wiki/Get-AccessToken
#
$clientId = "Please replace with your Application client ID"
$tenantName = "Please replace with your Tenant ID"
$clientSecret = "Please replace with your Application Secret key"
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
		write-host "Access token exist" -Foregroundcolor Green
		$logdata = "Access token exist"
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
# Assign value to variable
#
$AccessToken = Get-AccessToken -clientid $clientID -clientSecret $clientSecret -ErrorAction Stop
# 
################################################################################################################################################
################################################################################################################################################
# Function for Send Mail start
# Please grant application Mail send rights, see: https://github.com/lightupdifire/azuread/wiki/SendMail
# Mail can be sent from any mailbox in your organization
# I'm providing example for HTML mail format
#
Function SendMail () {
	param (
	[string]$FromAddress
	,[string]$ToAddress
	,[string]$AccessToken 
	)
$Headers = @{Authorization = "Bearer $AccessToken"}
$apiUrl = "https://graph.microsoft.com/v1.0/users/$FromAddress/sendMail"
$body = @"
{
  "message": {
    "subject": "Welcome to My Organization",
    "body": {
      "contentType": "HTML",
      "content": "Dear Colleague, <br><br>
	  Please proceed with <b>your account registration<b> using this <a href='https://account.activedirectory.windowsazure.com/applications/default.aspx?tenantId=$TenantName&amp;login_hint=$ToAddress'>LINK</a>
	  <br><br>
	  Best regards<br>
	  IT Support
	  "
    },
    "toRecipients": [
      {
        "emailAddress": {
          "address": "$ToAddress"
        }
      }
    ]
  },
  "saveToSentItems": "true"
}
"@
Invoke-RestMethod -Headers $Headers -Uri $apiUrl -Body $Body -Method Post -ContentType 'application/json'
}
#
# Function for Send Mail end
################################################################################################################################################
################################################################################################################################################
# For mail send, please replace values below before run script
#
$FromAddress = "Please replace with email address FROM which mail should be sent"
$ToAddress = "Please replace with email address TO whom mail should be sent"
#
# Calling function
#
SendMail -FromAddress $FromAddress -ToAddress $ToAddress -AccessToken $AccessToken
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
# 
################################################################################################################################################
################################################################################################################################################