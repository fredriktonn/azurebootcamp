

###### image and vhd for vm needs to be in the same storage account
### OBS! you need to create a VNET and resource group first

### to create image >az image create -g HackatonRG --name hackatonImage --os-type Windows --source https://mkhackaton.blob.core.windows.net/vhd/hackaton.vhd




Login-AzureRmAccount

Select-AzureRmSubscription -SubscriptionId "e9aac0f0-83bd-43cf-ab35-c8e3eccc8932"


$RGName                = "LabImage"

$storageAccName        = "labdisk"

$COmputerName          = "VMNew"

$urlOfCapturedImageVhd = "https://labdisk.blob.core.windows.net/vhds/devMachineBackup.vhd"

$location              = "West Europe"

$vmName                = "VMNew"

$osDiskName            = "baseDev"

#Enter a new user name and password in the pop-up for the following

$cred = Get-Credential

# Set the existing virtual network and subnet index

$vnetName="Test-vnet"

$subnetIndex=0

$vnet=Get-AzureRMVirtualNetwork -Name $vnetName -ResourceGroupName $rgName

# Create the NIC.

$nicName="VM02-NIC"

$pip=New-AzureRmPublicIpAddress -Name $nicName -ResourceGroupName $rgName -Location $location -AllocationMethod Dynamic

$nic=New-AzureRmNetworkInterface -Name $nicName -ResourceGroupName $rgName -Location $location -SubnetId $vnet.Subnets[$subnetIndex].Id -PublicIpAddressId $pip.Id

#Get the storage account where the captured image is stored

$storageAcc = Get-AzureRmStorageAccount -ResourceGroupName $rgName -AccountName $storageAccName

#Set the VM name and size

$vmConfig = New-AzureRmVMConfig -VMName $vmName -VMSize "Standard_D2s_v3"

#Set the Windows operating system configuration and add the NIC

$vm = Set-AzureRmVMOperatingSystem -VM $vmConfig -Windows -ComputerName $computerName -Credential $cred -ProvisionVMAgent -EnableAutoUpdate

$vm = Add-AzureRmVMNetworkInterface -VM $vm -Id $nic.Id

#Create the OS disk URI

$osDiskUri = '{0}vhds/{1}{2}.vhd' -f $storageAcc.PrimaryEndpoints.Blob.ToString(), $vmName.ToLower(), $osDiskName

#Configure the OS disk to be created from image (-CreateOption fromImage) and give the URL of the captured image VHD for the -SourceImageUri parameter.

#We found this URL in the local JSON template in the previous sections.

#$vm = Set-AzureRmVMOSDisk -VM $vm -Name $osDiskName -VhdUri $osDiskUri -CreateOption fromImage -SourceImageUri $urlOfCapturedImageVhd -Windows

$vm = Set-AzureRmVMOSDisk -VM $vm -Name $osDiskName -VhdUri $osDiskUri  -SourceImageUri $urlOfCapturedImageVhd -Windows


#Create the new VM

New-AzureRmVM -ResourceGroupName $rgName -Location $location -VM $vm