
[System.Collections.ArrayList]$saUsage = New-Object -TypeName System.Collections.ArrayList

$subscriptions = Get-AzSubscription

## ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## Get and list all Azure classic subscription administrators for each subscription

foreach ($sub in $subscriptions) {
    Set-AzContext -SubscriptionId $sub.Id | Out-Null
    $classicAdmins = Get-AzRoleAssignment -IncludeClassicAdministrators | Where-Object {$_.RoleDefinitionName -like "*ServiceAdministrator*" -or $_.RoleDefinitionName -like "*CoAdministrator*"}

    Write-Output "Subscription: $($sub.Name) - $($sub.Id)"
    if ($classicAdmins) {
        foreach ($admin in  $classicAdmins) {
            Write-Output "Classic Administrator: $($admin.SignInName)" 
            $classicAdminDetails = [ordered]@{
                SubscrpitionID = $sub.Id
                SubscriptionName = $sub.Name
                ClassicAdministrator = $admin.SignInName
            }
        $saUsage.add((New-Object psobject -Property $classicAdminDetails)) | Out-Null
        }
    } 
    else {
        Write-Host ( "No classic administrators found")
    }
}

$CurrentPath = Get-Location
$CurrentPath = $CurrentPath.Path + "\DTFS-classicAdmins.csv"
$saUsage | Export-Csv -Path $CurrentPath -NoTypeInformation


Write-Host ("Script completed" )

