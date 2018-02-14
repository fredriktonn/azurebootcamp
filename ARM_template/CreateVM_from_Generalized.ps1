

$imageURI = "https://devbaseimagedisks222.blob.core.windows.net/system/Microsoft.Compute/Images/images/devHack-osDisk.22d380a5-674b-45e5-b3b9-bcebdd148257.vhd"
$rgName = "DevBaseImage"
$subnetName = "4devSubnet"

# Name of the new virtual machine. This example sets the VM name as "myVM".
$vmName = "4devVMv"



############# VM settings ####################


# Name of the storage account where the VHD is located. This example sets the 
# storage account name as "myStorageAccount"
$storageAccName = "devbaseimagedisks222"

# Size of the virtual machine. This example creates "Standard_D2_v2" sized VM. 
# See the VM sizes documentation for more information: 
# https://azure.microsoft.com/documentation/articles/virtual-machines-windows-sizes/
$vmSize = "Standard_DS2_v2"

# Computer name for the VM. This examples sets the computer name as "myComputer".
$computerName = "4devBase"

# Name of the disk that holds the OS. This example sets the 
# OS disk name as "myOsDisk"
$osDiskName = "4myOsDisk"

# Assign a SKU name. This example sets the SKU name as "Standard_LRS"
# Valid values for -SkuName are: Standard_LRS - locally redundant storage, Standard_ZRS - zone redundant
# storage, Standard_GRS - geo redundant storage, Standard_RAGRS - read access geo redundant storage,
# Premium_LRS - premium locally redundant storage. 
$skuName = "Premium_LRS"


##############################################


#######################   CREATE IMAGE  ----> ###############

$rgGeneralized = "DevBaseImage"
$vmGeneralized = "baseDev"
$generalizedContainer = "images"
$prefix = "devHack"


Stop-AzureRmVM -ResourceGroupName  $rgGeneralized -Name $vmGeneralized"
Set-AzureRmVm -ResourceGroupName $rgGeneralized -Name $vmGeneralized" -Generalized

$vmGeneralizedStatus = Get-AzureRmVM -ResourceGroupName $rgGeneralized -Name $vmGeneralized -Status
$vmGeneralizedStatus.Statuses


Save-AzureRmVMImage -ResourceGroupName $rgGeneralized -Name $vmGeneralized `
    -DestinationContainerName $generalizedContainer -VHDNamePrefix $prefix `
    -Path "C:\Filename.json"


#######################  <---- CREATE IMAGE ###############



$singleSubnet = New-AzureRmVirtualNetworkSubnetConfig -Name $subnetName -AddressPrefix 10.0.0.0/24

$location = "West Europe"
$vnetName = "4devVnet"
$vnet = New-AzureRmVirtualNetwork -Name $vnetName -ResourceGroupName $rgName -Location $location `
    -AddressPrefix 10.0.0.0/16 -Subnet $singleSubnet

    $ipName = "devPip"
$pip = New-AzureRmPublicIpAddress -Name $ipName -ResourceGroupName $rgName -Location $location `
    -AllocationMethod Dynamic

    $nicName = "4devNic"
$nic = New-AzureRmNetworkInterface -Name $nicName -ResourceGroupName $rgName -Location $location `
    -SubnetId $vnet.Subnets[0].Id -PublicIpAddressId $pip.Id

    $nsgName = "4devNsg"

$rdpRule = New-AzureRmNetworkSecurityRuleConfig -Name myRdpRule -Description "Allow RDP" `
    -Access Allow -Protocol Tcp -Direction Inbound -Priority 110 `
    -SourceAddressPrefix Internet -SourcePortRange * `
    -DestinationAddressPrefix * -DestinationPortRange 3389

$nsg = New-AzureRmNetworkSecurityGroup -ResourceGroupName $rgName -Location $location `
    -Name $nsgName -SecurityRules $rdpRule


    $vnet = Get-AzureRmVirtualNetwork -ResourceGroupName $rgName -Name $vnetName




    ##### ************** VM CREATE ********************
    # Enter a new user name and password to use as the local administrator account 
    # for remotely accessing the VM.
    $cred = Get-Credential

  

    

   

    # Get the storage account where the uploaded image is stored
    $storageAcc = Get-AzureRmStorageAccount -ResourceGroupName $rgName -AccountName $storageAccName

    # Set the VM name and size
    $vmConfig = New-AzureRmVMConfig -VMName $vmName -VMSize $vmSize

    #Set the Windows operating system configuration and add the NIC
    $vm = Set-AzureRmVMOperatingSystem -VM $vmConfig -Windows -ComputerName $computerName `
        -Credential $cred -ProvisionVMAgent -EnableAutoUpdate
    $vm = Add-AzureRmVMNetworkInterface -VM $vm -Id $nic.Id

    # Create the OS disk URI
    #$osDiskUri = '{0}vhds/{1}-{2}.vhd' `
      #  -f $storageAcc.PrimaryEndpoints.Blob.ToString(), $vmName.ToLower(), $osDiskName

    # Configure the OS disk to be created from the existing VHD image (-CreateOption fromImage).
    $vm = Set-AzureRmVMOSDisk -VM $vm -Name $osDiskName -VhdUri $osDiskUri `
        -CreateOption fromImage -SourceImageUri $imageURI -Windows

    # Create the new VM
    New-AzureRmVM -ResourceGroupName $rgName -Location $location -VM $vm