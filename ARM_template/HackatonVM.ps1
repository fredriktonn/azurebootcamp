

#Login-AzureRmAccount
#Get-AzureRmSubscription
#Select-AzureRmSubscription -SubscriptionId 
#Stop-AzureRmVM -ResourceGroupName <resourceGroup> -Name 
#Set-AzureRmVm -ResourceGroupName <resourceGroup> -Name <vmName> -Generalized
#$vm = Get-AzureRmVM -ResourceGroupName <resourceGroup> -Name <vmName> -Status
#$vm.Statuses



AzCopy /Source:https://azbcdiag124.blob.core.windows.net/vhds /SourceKey:a+LARGsqUxDC1Ua5ttvURex730BTuqKMXrpydHia2nfiYWccMKy1B1nVUnV8vwc5zHehpqSzzoTFWfjRmTPXkg== /Dest:https://azbclab.blob.core.windows.net/vhd /DestKey:K/veu7XI3GPDtjChzdq5DlgCzlq47Tc8BcPYKuej8sTb7TR1CrTkHplRNEHLFDAXjEuT7xpgiXJ6yJ4hk1hGqA== /Pattern:devazbc20170829071746.vhd



#############

###CLI in Azure portal

az image create -g MyCliRg -n image1 --os-type Windows --source https://azbcdiag124.blob.core.windows.net/vhds/devazbc20170829071746.vhd

##########################


$rgName = "HackatonRG"
#$vmName = "devHackatonVM"
$location = "West Europe" 
$imageName = "HackatonImage"
$osVhdUri = "https://azbclab.blob.core.windows.net/vhds/devazbc20170829071746.vhd"


#Stop-AzureRmVM -ResourceGroupName $rgName -Name $vmName -Force
#Set-AzureRmVm -ResourceGroupName $rgName -Name $vmName -Generalized

$imageConfig = New-AzureRmImageConfig -Location $location
$imageConfig = Set-AzureRmImageOsDisk -Image $imageConfig -OsType Windows -OsState Generalized -BlobUri $osVhdUri
$image = New-AzureRmImage -ImageName $imageName -ResourceGroupName $rgName -Image $imageConfig



az image create -g MYCliRG -name hackatonImage --os-type Windows --source https://azbclab.blob.core.windows.net/vhd


az storage blob copy start --destination-blob hacakton.vhd --destination-container vhds 



az storage container create -n vhds –account-name azbclab –account-key K/veu7XI3GPDtjChzdq5DlgCzlq47Tc8BcPYKuej8sTb7TR1CrTkHplRNEHLFDAXjEuT7xpgiXJ6yJ4hk1hGqA==

az storage blob copy start --destination-container vhds --destination-blob hackaton.vhd --account-name arrastorg --account-key t+c468cx6G94EGFoqUOzoot1d0eJHyrUSakAfI7dtUG5qY5lfJJSiR8zuh3j0xucuK0cz1AKT7xLazehY/fgvQ==  --source-uri https://azbclab.blob.core.windows.net/vhd/devazbc20170829071746.vhd??sv=2017-04-17&ss=b&srt=co&sp=r&se=2020-08-29T23:29:45Z&st=2017-08-29T10:29:45Z&spr=https&sig=mO6aGTqglUTDT9DX3vnre8gYGexYsN2WrwsYj1jdH3A%3D


az storage blob copy start --destination-container vhds --destination-blob hackaton.vhd --account-key 2Kl/ERff0iWv09nX8cR6fkA0jDZjw5YiLJ2PwqRAmpUzVLEZvooNTKrhdBsfBNrhqSwwpg2MlgMrtrvGbMcYww== --account-name mkhackaton --source-account-key K/veu7XI3GPDtjChzdq5DlgCzlq47Tc8BcPYKuej8sTb7TR1CrTkHplRNEHLFDAXjEuT7xpgiXJ6yJ4hk1hGqA== --source-account-name azbclab --source-blob devazbc20170829071746.vhd --source-container vhd



# denna funkar!
az storage blob copy start --destination-container vhd --destination-blob hackaton.vhd --account-key 2Kl/ERff0iWv09nX8cR6fkA0jDZjw5YiLJ2PwqRAmpUzVLEZvooNTKrhdBsfBNrhqSwwpg2MlgMrtrvGbMcYww== --account-name mkhackaton --source-account-key K/veu7XI3GPDtjChzdq5DlgCzlq47Tc8BcPYKuej8sTb7TR1CrTkHplRNEHLFDAXjEuT7xpgiXJ6yJ4hk1hGqA== --source-account-name azbclab --source-blob devazbc20170829071746.vhd --source-container vhd
az image create -g HackatonRG --name hackatonImage --os-type Windows --source https://mkhackaton.blob.core.windows.net/vhd/hackaton.vhd --location "West Europe"





#####################

AzCopy /Source:https://azbcdiag124.blob.core.windows.net/vhds /SourceKey:a+LARGsqUxDC1Ua5ttvURex730BTuqKMXrpydHia2nfiYWccMKy1B1nVUnV8vwc5zHehpqSzzoTFWfjRmTPXkg== /Dest:https://azbclab.blob.core.windows.net/vhd /DestKey:K/veu7XI3GPDtjChzdq5DlgCzlq47Tc8BcPYKuej8sTb7TR1CrTkHplRNEHLFDAXjEuT7xpgiXJ6yJ4hk1hGqA== /Pattern:devazbc20170829071746.vhd

############3


$subnetName = "hackatonSubnet"
$singleSubnet = New-AzureRmVirtualNetworkSubnetConfig -Name $subnetName -AddressPrefix 10.0.0.0/24

$vnetName = "hackatonVnet"
$vnet = New-AzureRmVirtualNetwork -Name $vnetName -ResourceGroupName $rgName -Location $location `
    -AddressPrefix 10.0.0.0/16 -Subnet $singleSubnet

    $ipName = "hackatonIP"
$pip = New-AzureRmPublicIpAddress -Name $ipName -ResourceGroupName $rgName -Location $location `
    -AllocationMethod Dynamic

    $nicName = "hackatonNic"
$nic = New-AzureRmNetworkInterface -Name $nicName -ResourceGroupName $rgName -Location $location `
    -SubnetId $vnet.Subnets[0].Id -PublicIpAddressId $pip.Id

    $nsgName = "hackatonNSG"
$ruleName = "RdpRule"
$rdpRule = New-AzureRmNetworkSecurityRuleConfig -Name $ruleName -Description "Allow RDP" `
    -Access Allow -Protocol Tcp -Direction Inbound -Priority 110 `
    -SourceAddressPrefix Internet -SourcePortRange * `
    -DestinationAddressPrefix * -DestinationPortRange 3389

$nsg = New-AzureRmNetworkSecurityGroup -ResourceGroupName $rgName -Location $location `
    -Name $nsgName -SecurityRules $rdpRule

$vnet = Get-AzureRmVirtualNetwork -ResourceGroupName $rgName -Name $vnetName



$cred = Get-Credential


$vmName = "hackatonVM"
$computerName = "hackatonVM"

$vmSize = "E2S_V3_Standard"

$vm = New-AzureRmVMConfig -VMName $vmName -VMSize $vmSize
$vm = Set-AzureRmVMSourceImage -VM $vm -Id $image.Id

$vm = Set-AzureRmVMOSDisk -VM $vm  -StorageAccountType PremiumLRS -DiskSizeInGB 128 `
-CreateOption FromImage -Caching ReadWrite

$vm = Set-AzureRmVMOperatingSystem -VM $vm -Windows -ComputerName $computerName `
-Credential $cred -ProvisionVMAgent 

#-EnableAutoUpdate

$vm = Add-AzureRmVMNetworkInterface -VM $vm -Id $nic.Id


New-AzureRmVM -VM $vm -ResourceGroupName $rgName -Location $location


$vmList = Get-AzureRmVM -ResourceGroupName $rgName
$vmList.Name

