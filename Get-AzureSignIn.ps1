Function Get-AzureSignIn {
    [CmdletBinding()]
    param(
        [parameter(ValueFromPipeline, Mandatory = $True)]
        [OutputType([AzureSignIn[]])]
        [array]$InputObject

    )
    begin{

    }

    process {
        [AzureSignIn]::SignInReport($InputObject)
    }
}