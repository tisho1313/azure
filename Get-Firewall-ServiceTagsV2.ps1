Write-Host "Gathering Firewall rules..`n"
[System.Collections.ArrayList]$nsgList = New-Object -TypeName System.Collections.ArrayList

$fwPol = "afwp-dtfs-lz-we-001"
$resourceGroupName = "rg-dtfs-network-lz-we-001"

$subscriptionMy = Get-AzSubscription -SubscriptionId "27e6af69-d974-45a4-881d-ed6822fb46d0"
Set-AzContext -SubscriptionObject $subscriptionMy
# Get the config of the current Azure Firewall Policy
 $azFwPol = Get-AzFirewallPolicy -Name $fwPol -ResourceGroupName $resourceGroupName

 # Get RCGs IDs (didn't found a command that retrieve directly the RCGs Names)
 $rcgsIds = $azFwPol.RuleCollectionGroups

 # Get RCGs Names from RCGs IDs
 $rcgsNames =  foreach($rcgId in $rcgsIds) {
     $rcgId.Id.Substring($rcgId.Id.LastIndexOf("/")+1)
 }

 # For each RCG 
foreach($rcgName in $rcgsNames) {
    #if ($rcgName -eq "DefaultNetworkRuleCollectionGroup"){
        # Get Azure RCG object
        $rcg = Get-AzFirewallPolicyRuleCollectionGroup -Name $rcgName -AzureFirewallPolicyName $fwPol -ResourceGroupName $resourceGroupName

        foreach($ruleCollection in $rcg.Properties.RuleCollection){
            $sourceStr = ""
            $destStr = ""
            foreach($rule in $ruleCollection.Rules){
                foreach($sourceAddr in $rule.SourceAddresses){
                    if($sourceAddr -eq "AzureUpdateDelivery" -Or $sourceAddr -eq "AzureFrontDoor.FirstParty"){
                        Write-Host $rule.Name
                        $sourceStr = $sourceAddr
                    }
                }
                foreach($destAddr in $rule.DestinationAddresses){
                    if($destAddr -eq "AzureUpdateDelivery" -Or $destAddr -eq "AzureFrontDoor.FirstParty"){
                        Write-Host $rule.Name
                        $destStr = $destAddr
                    }
                }   
            }
            $nsgDetails = [ordered]@{
                rcgName = $rcgName
                ruleName = $rule.Name
                sourceAddr = $sourceStr
                destStr = $destStr
            }
            $nsgList.add((New-Object psobject -Property $nsgDetails)) | Out-Null 
        }   
    #}
}

$CurrentPath = Get-Location
$CurrentPath = $CurrentPath.Path + "\Firewall-Network-Rules-1.0.csv"
$nsgList | Export-Csv -Path $CurrentPath -NoTypeInformation
