function Get-UserSignInReport {
    param (
        [parameter(ParameterSetName = "Default")]
        [switch]$FullReport,
        [parameter(ParameterSetName = "User")]
        [switch]$User,
        [parameter(ParameterSetName = "User")]
        [string]$UserName
    )

    $Script:Filter = "createdDateTime gt $((get-date).AddDays(-7).ToString("yyyy-MM-dd")) and UserDisplayName ne 'On-Premises Directory Synchronization Service Account' and status/errorCode ne 0"
    try {
        $Script:AzureSigninLog = Get-AzureADAuditSignInLogs -Filter $Script:Filter | Get-AzureSignIn
    }
    catch {
        throw "Sign into Azure AD First"
        return
    }
    try {
    }
    catch {
        try {
            Connect-MgGraph -Scopes "UserAuthenticationMethod.Read.All, Directory.Read.All, User.Read.All, Auditlog.Read.All"
        }
        catch {
            throw "Sign Into Graph"
            return
        }
    }
    $Script:GraphUsers = Get-MgUser -all
    $Script:GraphUserIndex = $Script:GraphUsers | Group-Object DisplayName -AsHashTable -AsString
    $Script:AzureSigninIndex = $Script:AzureSigninLog | Group-Object UserDisplayName -AsHashTable -AsString
    $Script:UsersToProcess = $Script:AzureSigninLog | Select-Object UserDisplayName -Unique
    if ($FullReport) {
        $Script:Report = Foreach ($i in $Script:UsersToProcess) {
            try {
                $Script:MFAMethod = Get-MgUserAuthenticationMethod -UserId $Script:GraphUserIndex[$i.UserDisplayName][0].Id
            }
            catch {
            }
            [PSCustomObject]@{
                Name            = $i.UserDisplayName
                IPAddress       = $Script:AzureSigninIndex[$i.UserDisplayName].IPAddress | Select-Object -Unique
                ErrorCode       = $Script:AzureSigninIndex[$i.UserDisplayName].ErrorCode | Select-Object -Unique
                FailureReason   = $Script:AzureSigninIndex[$i.UserDisplayName].FailureReason | Select-Object -Unique
                OperatingSystem = $Script:AzureSigninIndex[$i.UserDisplayName].OperatingSystem | Select-Object -Unique
                Browser         = $Script:AzureSigninIndex[$i.UserDisplayName].Browser | Select-Object -Unique
                Location        = $Script:AzureSigninIndex[$i.UserDisplayName].Location | Select-Object -Unique
                FailureCount    = ($Script:AzureSigninIndex[$i.UserDisplayName]).count
                MFAMethod       = switch ($Script:MFAMethod.AdditionalProperties."@odata.type" | Select-Object -Unique) {
                    "#microsoft.graph.phoneAuthenticationMethod"                    { "Phone" }
                    "#microsoft.graph.microsoftAuthenticatorAuthenticationMethod"   { "Microsoft Authenticator" }
                    "#microsoft.graph.passwordAuthenticationMethod"                 { "Password" }
                    "#microsoft.graph.windowsHelloForBusinessAuthenticationMethod"  { "Windows Hello" }
                    "#microsoft.graph.emailAuthenticationMethod"                    { "Email" }
                    "microsoft.graph.temporaryAccessPassAuthenticationMethod"       { "Temporary Access Pass" }
                    "#microsoft.graph.passwordlessMicrosoftAuthenticatorAuthenticationMethod" { "Passwordless Microsoft Authenticator" }
                    default { "Unknown" }
                } 
            }
        }
        $Script:Report | Out-GridView -Title "Azure Sign In Report"
    }
    if ($User) {
        $Script:UserToProcess = $Script:AzureSigninIndex[$UserName]
        $Script:Report = for ($i = 0; $i -lt $UsersToProcess.count; $i++) {
            [PSCustomObject]@{
                Name            = $UserName
                IPAddress       = $Script:UserToProcess[$i].IPAddress 
                ErrorCode       = $Script:UserToProcess[$i].ErrorCode 
                FailureReason   = $Script:UserToProcess[$i].FailureReason 
                OperatingSystem = $Script:UserToProcess[$i].OperatingSystem 
                Browser         = $Script:UserToProcess[$i].Browser 
                Location        = $Script:UserToProcess[$i].Location 
                FailureCount    = ($Script:UserToProcess[$i]).count
                MFAMethod       = switch ($Script:GraphUserIndex[$i.UserDisplayName].AdditionalProperties."@odata.type" | Select-Object -Unique) {
                    "#microsoft.graph.phoneAuthenticationMethod"                    { "Phone" }
                    "#microsoft.graph.microsoftAuthenticatorAuthenticationMethod"   { "Microsoft Authenticator" }
                    "#microsoft.graph.passwordAuthenticationMethod"                 { "Password" }
                    "#microsoft.graph.windowsHelloForBusinessAuthenticationMethod"  { "Windows Hello" }
                    "#microsoft.graph.emailAuthenticationMethod"                    { "Email" }
                    "microsoft.graph.temporaryAccessPassAuthenticationMethod"       { "Temporary Access Pass" }
                    "#microsoft.graph.passwordlessMicrosoftAuthenticatorAuthenticationMethod" { "Passwordless Microsoft Authenticator" }
                    default { "Unknown" }
                }
            }
        }
        $Script:Report | Out-GridView -Title "Azure Sign In Report"
    }
    
}