#Connect-AzAccount

Write-Host "Gathering storage account information...`n"
[System.Collections.ArrayList]$saUsage = New-Object -TypeName System.Collections.ArrayList

$subscriptions = Get-AzSubscription 


foreach ($subscription in $subscriptions)  {
    
    Set-AzContext -SubscriptionObject $subscription
    $context = Get-AzContext
    

    #$storageAccounts = Get-AzStorageAccount
    $storageAccounts = Get-AzResource -ResourceType  "Microsoft.Storage/storageAccounts"
  
    foreach ($storageAccount in $storageAccounts) {

            $StorageAccountDetails = [ordered]@{
                SubscrpitionID = $context.Subscription.Id
                ResourceGroup = $storageAccount.ResourceGroupName
                Location = $storageAccount.Location
                SubscrpitionName = $context.Subscription.Name
                StorageAccountName = $storageAccount.Name
                TLSVersion = $storageAccount.MinimumTlsVersion
            }
        $saUsage.add((New-Object psobject -Property $StorageAccountDetails)) | Out-Null
    }
}
$CurrentPath = Get-Location
$CurrentPath = $CurrentPath.Path + "\StorageAccounts-TLS-Versions.csv"
$saUsage | Export-Csv -Path $CurrentPath -NoTypeInformation
