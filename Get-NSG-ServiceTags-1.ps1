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

        $NSGs = Get-AzNetworkSecurityGroup

        foreach($nsg in $NSGs){
            $sourceStr = ""
            $destStr   = ""
            foreach($secRule in  $nsg.DefaultSecurityRules){

                foreach($destination in $secRules.DestinationAddressPrefix){
                    if($destination -eq "AzureUpdateDelivery" -Or $destination -eq "AzureFrontDoor.FirstParty"){
                        Write-Host $nsg.Name
                        $destStr = $destination
                    }
                }
                foreach($source in $secRules.SourceAddressPrefix){
                    if($sourceSec -eq "AzureUpdateDelivery" -Or $sourceSec -eq "AzureFrontDoor.FirstParty"){
                        Write-Host $nsg.Name
                        $sourceStr = $sourceSec
                    }
                }

            }
            
            $nsgDetails = [ordered]@{
                Loccation = $nsg.Location
                ResourceGroupName = $nsg.ResourceGroupName
                NSG_Name = $nsg.Name
                sourceSec = $sourceStr
                destSec = $destStr
            }
            $nsgList.add((New-Object psobject -Property $nsgDetails)) | Out-Null   

        }
    }
}

$CurrentPath = Get-Location
$CurrentPath = $CurrentPath.Path + "\NSG-TagV1.3.csv"
$nsgList | Export-Csv -Path $CurrentPath -NoTypeInformation
