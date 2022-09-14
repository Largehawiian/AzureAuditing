function Get-UserMFAStatus {
    [CmdletBinding()]
    param (	
    )
    begin {
		
    }
    process {
        try {
            Connect-MgGraph -Scopes "UserAuthenticationMethod.Read.All, Directory.Read.All, User.Read.All, Auditlog.Read.All"
        }
        catch {
            throw "Sign Into Graph"
            return
        }
        $Script:GraphUsers = Get-MgUser -All
        $Script:GraphUserIndex = $Script:GraphUsers | Group-Object DisplayName -AsHashTable -AsString
        $Script:Report = foreach ($i in $Script:GraphUsers) {
            try {
                $Script:MFAMethod = Get-MgUserAuthenticationMethod -UserId $Script:GraphUserIndex[$i.UserDisplayName][0].Id
            }
            catch {
            }
            [PSCustomObject]@{
                UserName  = $i.DisplayName
                MFAMethod = switch ($Script:MFAMethod.AdditionalProperties."@odata.type" | Select-Object -Unique) {
                    "#microsoft.graph.phoneAuthenticationMethod" { "Phone" }
                    "#microsoft.graph.microsoftAuthenticatorAuthenticationMethod" { "Microsoft Authenticator" }
                    "#microsoft.graph.passwordAuthenticationMethod" { "Password" }
                    "#microsoft.graph.windowsHelloForBusinessAuthenticationMethod" { "Windows Hello" }
                    "#microsoft.graph.emailAuthenticationMethod" { "Email" }
                    "microsoft.graph.temporaryAccessPassAuthenticationMethod" { "Temporary Access Pass" }
                    "#microsoft.graph.passwordlessMicrosoftAuthenticatorAuthenticationMethod" { "Passwordless Microsoft Authenticator" }
                    default { "Unknown" }
                }
            }
        }	
        return $Script:Report | Sort-Object UserName
    }
    end {
    }
}