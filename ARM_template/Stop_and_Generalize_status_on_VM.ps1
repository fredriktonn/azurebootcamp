
$destinationResourceGroup = "StudentGeneralizedVM"
$destContainer = "vhds"
$vmName = "devVM"

### GENERALIZE THE VM 
Stop-AzureRmVM -ResourceGroupName $destinationResourceGroup -Name $vmName
Set-AzureRmVm -ResourceGroupName $destinationResourceGroup -Name $vmName -Generalized
$vm = Get-AzureRmVM -ResourceGroupName $destinationResourceGroup -Name $vmName -Status
$vm.Statuses

#create Image
Save-AzureRmVMImage -ResourceGroupName $destinationResourceGroup -Name $vmName `
   -DestinationContainerName $destContainer -VHDNamePrefix "Student_Image" `
  -Path "C:\Filename.json"