#Connect-AzAccount

Write-Host "Gathering storage account information...`n"
[System.Collections.ArrayList]$saUsage = New-Object -TypeName System.Collections.ArrayList

$subscriptions = Get-AzSubscription 


foreach ($subscription in $subscriptions)  {
    
    Set-AzContext -SubscriptionObject $subscription
    $context = Get-AzContext
    

    $storageAccounts = Get-AzStorageAccount
    
    foreach ($storageAccount in $storageAccounts) {

            $StorageAccountDetails = [ordered]@{
                SubscrpitionID = $context.Subscription.Id
                ResourceGroup = $storageAccount.ResourceGroupName
                Location = $storageAccount.Location
                SubscrpitionName = $context.Subscription.Name
                StorageAccountName = $storageAccount.StorageAccountName
                TLSVersion = $storageAccount.MinimumTlsVersion
            }
        $saUsage.add((New-Object psobject -Property $StorageAccountDetails)) | Out-Null
    }
}
$saUsage | Export-Csv -Path C:\Temp\StorageAccounts-TLS-Versions.csv -NoTypeInformation
