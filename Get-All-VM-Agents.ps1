# Get-AzVM

#Connect-AzAccount

Write-Host "Gathering All VMs..`n"
[System.Collections.ArrayList]$nsgList = New-Object -TypeName System.Collections.ArrayList

$subscriptions = Get-AzSubscription 

foreach ($subscription in $subscriptions){
    Set-AzContext -SubscriptionObject $subscription
    $allResourceGroups = Get-AzResourceGroup 
    
    foreach($ResourceGroup in $allResourceGroups){

        $VMs = Get-AzVM -ResourceGroupName $ResourceGroup.ResourceGroupName
        
        foreach($vm in $VMs){
                #$agent = $vm | Select -ExpandProperty OSProfile | Select -ExpandProperty Windowsconfiguration | Select ProvisionVMAgent
                $extensions = Get-AzVMExtension -VMObject $vm
                $extName = ""
                
                foreach($extOne in $extensions){
                    if ($extOne.Name.Contains("Monitor")){
                        $extName = $extOne.Name
                    }
                }
                
                $vmDetails = [ordered]@{
                    subscription = $subscription.Name
                    ResourceGroupName = $ResourceGroup.ResourceGroupName
                    vmName = $vm.Name
                    #agent = $agent.ProvisionVMAgent
                    Type = $vm.Type
                    extension = $extName
                }
                $nsgList.add((New-Object psobject -Property $vmDetails)) | Out-Null
        }
    }
}

$CurrentPath = Get-Location
$CurrentPath = $CurrentPath.Path + "\VM-ALL-Monitoring-Agents-DTFS-1.0.csv"
$nsgList | Export-Csv -Path $CurrentPath -NoTypeInformation
