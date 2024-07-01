#Connect-AzAccount

$CurrentPath = Get-Location
$date = Get-Date
$date = $date.ToString("yyyy-MM-dd-hh-mm-ss")

$subscriptions = Get-AzSubscription 

#create directory with date name
New-Item -Path $CurrentPath.Path -Name $date  -ItemType Directory
$FolderNameCurrent = $CurrentPath.Path + "\$date\" 

Start-Transcript -Path .\logOutResourceGroups.log

foreach ($subscription in $subscriptions){
    
    Set-AzContext -SubscriptionObject $subscription

    #create directory with the subscription  name
    New-Item -Path $FolderNameCurrent -Name $subscription.Name  -ItemType Directory

    $FolderNameSubs = $FolderNameCurrent  + $subscription.Name

    $allResourceGroups = Get-AzResourceGroup 
    
    foreach($ResourceGroup in $allResourceGroups){

        if($ResourceGroup.Location.Contains( "westeu")){
            
            $FolderResGroup =  $ResourceGroup.ResourceGroupName 
            New-Item -Path $FolderNameSubs -Name $FolderResGroup  -ItemType Directory
            
            $ResGroupPath = $FolderNameSubs + "\" + $FolderResGroup  +  "\" + $FolderResGroup + ".json"
            Export-AzResourceGroup  -ResourceGroupName $ResourceGroup.ResourceGroupName -Path $ResGroupPath
        }
    }
}

Stop-Transcript
