class AzureSignIn {
    [string]$UserDisplayName
    [string]$UserPrincipalName
    [string]$IPAddress
    [bool]$IsInteractive
    hidden[array]$status
    [int32]$ErrorCode
    [string]$FailureReason
    hidden[array]$DeviceDetail
    [string]$OperatingSystem
    [string]$Browser
    [string]$Location

    AzureSignIn () {}

    AzureSignIn ($UserDisplayName, $UserPrincipalName, $IPAddress, $IsInteractive,$Status,$ErrorCode,$FailureReason,$OperatingSystem, $Browser, $DeviceDetail, $Location){
        $this.UserDisplayName = $UserDisplayName
        $this.UserPrincipalName = $UserPrincipalName
        $this.IPAddress = $IPAddress
        $this.IsInteractive = $IsInteractive
        $this.ErrorCode = $Status.ErrorCode
        $this.FailureReason = $Status.FailureReason
        $this.OperatingSystem = $DeviceDetail.OperatingSystem
        $this.Browser = $DeviceDetail.Browser
        $this.Location = $Location.City.tostring() + " " + $Location.State.tostring() + " " + $Location.CountryOrRegion.tostring()
    }

    static [AzureSignIn]SignInReport ($InputObject){
        return [AzureSignIn]::New($InputObject.UserDisplayName, $InputObject.UserPrincipalName, $InputObject.IPAddress, $InputObject.IsInteractive, $InputObject.Status, "", "", "", "",$InputObject.DeviceDetail,$InputObject.Location)
    }
}