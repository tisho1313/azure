#Connect-AzAccount

function ParseIDs($textId){
    $Dictionary = @{}
    $splitedArray = $textId.Split("/")

    for ($i = 1; $i -lt $splitedArray.Count; $i++) {
        $Dictionary.Add($splitedArray[$i], $splitedArray[$i+1])
        $i++
    }
    
    $Dictionary
}

function ConvertTo-StringData {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [HashTable[]]$HashTable
    )
    process {
        foreach ($item in $HashTable) {
            foreach ($entry in $item.GetEnumerator()) {
                "{0}={1}" -f $entry.Key, $entry.Value
            }
        }
    }
}

Write-Host "Gathering NSGs..`n"
[System.Collections.ArrayList]$nsgList = New-Object -TypeName System.Collections.ArrayList

$subscriptions = Get-AzSubscription 

foreach ($subscription in $subscriptions){
    Set-AzContext -SubscriptionObject $subscription
    $allResourceGroups = Get-AzResourceGroup 
    
    foreach($ResourceGroup in $allResourceGroups){

        $NSGs = Get-AzNetworkSecurityGroup -ResourceGroupName $ResourceGroup.ResourceGroupName

        foreach($nsg in $NSGs){

            $nsg_one = Get-AzNetworkSecurityGroup -Name $nsg.Name -ResourceGroupName $ResourceGroup.ResourceGroupName -ExpandResource "NetworkInterfaces"
            
            foreach($NetInterface in $nsg_one.NetworkInterfaces){
                $interfaceName = ""
                $vmName  = ""
                if($null -ne $NetInterface.VirtualMachine){
                    $vmName =  $vmName + "   " + $NetInterface.VirtualMachine.Id.Split('/')[-1]
                    $interfaceName = $interfaceName + "   " + $NetInterface.Name                    
                }
            }

            # Default Security Rules
            foreach($secRule in  $nsg.DefaultSecurityRules){
                $sourceStr = ""
                $destStr   = ""

                foreach($destination in $secRule.DestinationAddressPrefix){
                    if($destination -eq "AzureUpdateDelivery" -Or $destination -eq "AzureFrontDoor.FirstParty"){
                        Write-Host $nsg.Name
                        $destStr = $destination
                    }
                }
                foreach($sourceSec in $secRule.SourceAddressPrefix){
                    if($sourceSec -eq "AzureUpdateDelivery" -Or $sourceSec -eq "AzureFrontDoor.FirstParty"){
                        Write-Host $nsg.Name
                        $sourceStr = $sourceSec
                    }
                }
                $nsgDetails = [ordered]@{
                    Loccation = $nsg.Location
                    ResourceGroupName = $nsg.ResourceGroupName
                    NSG_Name = $nsg.Name
                    SecRule = $secRule.Name
                    sourceSec = $sourceStr
                    destSec = $destStr
                    vmName  = $vmName
                    interfaceName = $interfaceName
                }
                $nsgList.add((New-Object psobject -Property $nsgDetails)) | Out-Null                

            }

            # Security Rules
            foreach($secRule in  $nsg.SecurityRules){
                $sourceStr = ""
                $destStr   = ""

                foreach($destination in $secRule.DestinationAddressPrefix){
                    if($destination -eq "AzureUpdateDelivery" -Or $destination -eq "AzureFrontDoor.FirstParty"){
                        Write-Host $nsg.Name
                        $destStr = $destination
                    }
                }
                foreach($sourceSec in $secRule.SourceAddressPrefix){
                    if($sourceSec -eq "AzureUpdateDelivery" -Or $sourceSec -eq "AzureFrontDoor.FirstParty"){
                        Write-Host $nsg.Name
                        $sourceStr = $sourceSec
                    }
                }
                $nsgDetails = [ordered]@{
                    Loccation = $nsg.Location
                    ResourceGroupName = $nsg.ResourceGroupName
                    NSG_Name = $nsg.Name
                    SecRule = $secRule.Name
                    sourceSec = $sourceStr
                    destSec = $destStr
                    vmName  = $vmName
                    interfaceName = $interfaceName
                }
                $nsgList.add((New-Object psobject -Property $nsgDetails)) | Out-Null                

            }
        }
    }
}

$CurrentPath = Get-Location
$CurrentPath = $CurrentPath.Path + "\NSG-Tag-V1.6.csv"
$nsgList | Export-Csv -Path $CurrentPath -NoTypeInformation
