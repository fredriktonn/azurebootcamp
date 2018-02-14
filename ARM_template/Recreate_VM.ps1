#Re-creates a specialized VM from VHD




function ReCreateVM(
$rgName,
$subnetName,
$location,
$vnetName,
$ipName ,
$nicName,
$nsgName,
$vmName ,
$osDiskUri,
$vmSize 
)

{
$randomnumber = Get-Random -Minimum 0 -Maximum 9999
$diagnosticsStorageAccount = "devazbc" + $randomnumber
$addressPrefix = "10.0.0.0/24"

$singleSubnet = New-AzureRmVirtualNetworkSubnetConfig -Name $subnetName -AddressPrefix $addressPrefix

"Create VNET"

$vnet = New-AzureRmVirtualNetwork -Name $vnetName -ResourceGroupName $rgName -Location $location `
    -AddressPrefix 10.0.0.0/16 -Subnet $singleSubnet

"Create PIP"

$pip = New-AzureRmPublicIpAddress -Name $ipName -ResourceGroupName $rgName -Location $location `
    -AllocationMethod Dynamic

"Create NIC"

$nic = New-AzureRmNetworkInterface -Name $nicName -ResourceGroupName $rgName `
-Location $location -SubnetId $vnet.Subnets[0].Id -PublicIpAddressId $pip.Id


$rdpRule = New-AzureRmNetworkSecurityRuleConfig -Name myRdpRule -Description "Allow RDP" `
    -Access Allow -Protocol Tcp -Direction Inbound -Priority 110 `
    -SourceAddressPrefix Internet -SourcePortRange * `
    -DestinationAddressPrefix * -DestinationPortRange 3389

"Create NSG"

$nsg = New-AzureRmNetworkSecurityGroup -ResourceGroupName $rgName -Location $location `
    -Name $nsgName -SecurityRules $rdpRule

Set-AzureRmVirtualNetworkSubnetConfig `
    -Name $subnetName `
    -VirtualNetwork $vnet `
    -NetworkSecurityGroup $nsg `
    -AddressPrefix $addressPrefix

$vnet | Set-AzureRmVirtualNetwork


$vmConfig = New-AzureRmVMConfig -VMName $vmName -VMSize $vmSize

$vm = Add-AzureRmVMNetworkInterface -VM $vmConfig -Id $nic.Id

$osDiskName = $vmName + "osDisk"
$vm = Set-AzureRmVMOSDisk -VM $vm -Name $osDiskName -VhdUri $osDiskUri -CreateOption attach -Windows

"Create STRG DIAGNOSTICS"

# Create a new storage account.
New-AzureRmStorageAccount -ResourceGroupName $rgName -AccountName $diagnosticsStorageAccount -Location $location -SkuName "Standard_LRS"


Set-AzureRmVMBootDiagnostics -VM $vm -Enable -ResourceGroupName $rgName -StorageAccountName $diagnosticsStorageAccount


# if using datadisks
#$dataDiskName = $vmName + "dataDisk"
#$vm = Add-AzureRmVMDataDisk -VM $vm -Name $dataDiskName -VhdUri $dataDiskUri -Lun 1 -CreateOption attach

"Create VM"

#Create the new VM
New-AzureRmVM -ResourceGroupName $rgName -Location $location -VM $vm

}

