function Get-UserSignInReport {
    param (
        [parameter(ParameterSetName = "Default")]
        [switch]$FullReport,
        [parameter(ParameterSetName = "User")]
        [switch]$User,
        [parameter(ParameterSetName = "User")]
        [string]$UserName
    )

    $Script:Filter = "createdDateTime gt $((get-date).AddDays(-7).ToString("yyyy-MM-dd")) and UserDisplayName ne 'On-Premises Directory Synchronization Service Account'"
    $Script:AzureSigninLog = Get-AzureADAuditSignInLogs -Filter $Script:Filter | Get-AzureSignIn
    $Script:AzureSigninIndex = $Script:AzureSigninLog | Group-Object UserDisplayName -AsHashTable -AsString
    $Script:UsersToProcess = $Script:AzureSigninLog | Select-Object UserDisplayName -Unique
    if ($FullReport) {
        $Script:Report = Foreach ($i in $Script:UsersToProcess) {
            [PSCustomObject]@{
                Name            = $i.UserDisplayName
                IPAddress       = $Script:AzureSigninIndex[$i.UserDisplayName].IPAddress | Select-Object -Unique
                ErrorCode       = $Script:AzureSigninIndex[$i.UserDisplayName].ErrorCode | Select-Object -Unique
                FailureReason   = $Script:AzureSigninIndex[$i.UserDisplayName].FailureReason | Select-Object -Unique
                OperatingSystem = $Script:AzureSigninIndex[$i.UserDisplayName].OperatingSystem | Select-Object -Unique
                Browser         = $Script:AzureSigninIndex[$i.UserDisplayName].Browser | Select-Object -Unique
                Location        = $Script:AzureSigninIndex[$i.UserDisplayName].Location | Select-Object -Unique
                FailureCount    = ($Script:AzureSigninIndex[$i.UserDisplayName]).count
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
            }
        }
    }
    $Script:Report | Out-GridView -Title "Azure Sign In Report"
}