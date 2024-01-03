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

Write-Host "Gathering NSGs..`n"
[System.Collections.ArrayList]$nsgList = New-Object -TypeName System.Collections.ArrayList

$subscriptions = Get-AzSubscription 

foreach ($subscription in $subscriptions){
    Set-AzContext -SubscriptionObject $subscription
    $allResourceGroups = Get-AzResourceGroup 
    
    foreach($ResourceGroup in $allResourceGroups){

        $NSGs = Get-AzNetworkSecurityGroup
        
        foreach($nsg in $NSGs){

            foreach($subnet in $nsg.Subnets){
                $subnetProeprties = ParseIDs($subnet.Id)
                $Vnet1 = Get-AzVirtualNetwork -Name $subnetProeprties.virtualNetworks
                $VnetConfig1 = Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $Vnet1
                $AddressPrefix =($VnetConfig1 | Where-Object {$_.Name -match $subnetProeprties.subnets}).AddressPrefix
                $AddressPrefixStr = $AddressPrefix -join " | "
                $nsgDetails = [ordered]@{
                    Loccation = $nsg.Location
                    ResourceGroupName = $nsg.ResourceGroupName
                    NSG_Name = $nsg.Name
                    VnetName = $subnetProeprties.virtualNetworks
                    SubnetName = $subnetProeprties.subnets
                    AddressPrefix = $AddressPrefixStr
                }
                $nsgList.add((New-Object psobject -Property $nsgDetails)) | Out-Null
            }
        }
    }
}

$CurrentPath = Get-Location
$CurrentPath = $CurrentPath.Path + "\NSG-DetailsV2.1.csv"
$nsgList | Export-Csv -Path $CurrentPath -NoTypeInformation
