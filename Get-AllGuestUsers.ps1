################################################################################################################################################
################################################################################################################################################
# 
# This script receive access token and receive all guest users from Azure AD tenant
# Access Token is valid for 1 hour as a default configuration of Azure AD
# When Access Token received, can operate with Graph  API with other operations like update/disable/create user etc.
# Please Register Web Application in Azure AD and grant permissions, see: https://github.com/lightupdifire/azuread/wiki/Get-AccessToken
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
$clientId = "Please replace with your Application client ID"
$tenantName = "Please replace with your Tenant ID"
$clientSecret = "Please replace with your Application Secret key"
#
# Set Logging
#
$workdir = Get-Location
$date = Get-Date
$logfile = "$workdir\" + "Get-AllGuestUsers_" + $date.day + "-" + $date.month + "-" + $date.year + ".log"
$Transcript = "$workdir\" + "Get-AllGuestUsers_transcript" + $date.day + "-" + $date.month + "-" + $date.year + ".log"
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
# Function to receive All Guest users from Azure tenant
#
Function Get-GuestUsers(){
	param (
		[string]$AccessToken
	)
try {
$GraphUsers = @()
#
# Note!
# The URI below can be changed and added other fields if needed, at this moment selecting only DisplayName, Mail, UserPrincipalName, ID , UserType
#
$uri = "https://graph.microsoft.com/v1.0/users?$`select=displayName,mail,userPrincipalName,id,userType&`$top=999&`$filter=userType eq 'Guest'"
do {
    $result = Invoke-RestMethod -Headers @{Authorization = "Bearer $AccessToken"} -Uri $uri -Method Get -ErrorAction Stop
    $uri = $result.'@odata.nextLink'
    # Adding delay to avoid throttling
	sleep 3
    $GraphUsers += $result.Value
} while ($uri)
# 
# Setting for progress view start
# 
$Output = @()
$count = 1; $PercentComplete = 0;
#
# Setting for progress view end
#
# ForEach start
#
ForEach ($user in $GraphUsers) {
    #
	# Progress view start
	#
    $ActivityMessage = "Retrieving data for user $($user.displayName). Please wait..."
    $StatusMessage = ("Processing user {0} of {1}: {2}" -f $count, @($GraphUsers).count, $user.userPrincipalName)
    $PercentComplete = ($count / @($GraphUsers).count * 100)
    Write-Progress -Activity $ActivityMessage -Status $StatusMessage -PercentComplete $PercentComplete
    $count++
	#
	# Progress view end
	#
	$ResponseUser = New-Object -TypeName PSObject
    # Adding delay to avoid throttling
    sleep 3
    Write-Verbose "Processing user $($user.userPrincipalName)..."
    $UserID = $user.id
    $uri = "https://graph.microsoft.com/v1.0/users/$($user.id)/mail"
	$user = Invoke-RestMethod -Headers @{Authorization = "Bearer $AccessToken"} -Uri $uri -Method Get -ErrorAction Stop
	#
	# Adding table with users, adding needed info only: Guest user registered email address and user ID in Azure
	#
	$ResponseUser | Add-Member -Name "GuestUserUsername" -MemberType NoteProperty -Value $user.Value
    $ResponseUser | Add-Member -Name "GuestUserID" -MemberType NoteProperty -Value $UserID
	$ResponseUsers += [Array]$ResponseUser
}
#
# ForEach end
#
# If data received from ForEach loop, then return data
#
		if ($ResponseUsers){
			return $ResponseUsers
		}
	# If users not received, stop function and exit script
		else
			{
			write-host "This is from Get-GuestUsers function, Fail to get Guest users, stopping script" -ForegroundColor Red
			$logdata = "This is from Get-GuestUsers function, Fail to get Guest users, stopping script" 
			$logdata | out-file -filepath $logfile -Append
			break
			exit
			}
# Catch error if any and store in log file
	} catch {
			$ErrorMessage = $_.Exception.Message
			write-host "This is from Get-GuestUsers function, Error: $ErrorMessage" -ForegroundColor Red
			$logdata = "This is from Get-GuestUsers function, Error: $ErrorMessage"
			$logdata | out-file -filepath $logfile -Append
			}
}
#
#
$users = Get-GuestUsers -AccessToken $AccessToken
#
# Do some action with users
# 
ForEach ($user in $users){
write-host "Guest User: $($user.GuestUserUsername) with ID: $($user.GuestUserID) received from Azure AD" -ForeGroundColor Green
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
# 
