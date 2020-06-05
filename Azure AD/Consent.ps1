$clientId = "905a54f2-7f75-4bb0-b898-38ca1bb673d0"
$tenantName = "8f18eb27-4f87-4a88-b325-f8e6e7e43486"
$clientSecret = "07341dcb-967c-461c-bf0d-a7ecaceb3f2e"


$ReqTokenBody = @{
    Grant_Type    = "client_credentials"
    Scope         = "https://graph.microsoft.com/.default"
    client_Id     = $clientID
    Client_Secret = $clientSecret
} 

$TokenResponse = Invoke-RestMethod -Uri "https://login.microsoftonline.com/$TenantName/oauth2/v2.0/token" -Method POST -Body $ReqTokenBody

$apiUrl = "https://graph.microsoft.com/beta/oauth2PermissionGrants"


$body = @{
    clientId    = "44b76cf0-d116-46d9-aee1-8d16587a61f8"
    consentType = "AllPrincipals"
    principalId = $null
    resourceId  = "4fc5a2fe-a92e-4b0e-8873-4d0eabcac49f"
    scope       = "Group.Read.All"
    startTime   = "2016-10-19T10:37:00Z"
    expiryTime  = "2016-10-19T10:37:00Z"
}

Invoke-RestMethod -Uri $apiUrl -Headers @{Authorization = "Bearer $($Tokenresponse.access_token)" }  -Method POST -Body $($body | convertto-json) -ContentType "application/json"