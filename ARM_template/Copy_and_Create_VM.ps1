. "C:\arashms\Hackaton Search\ARM_template\Copy_VHD_Between_subs.ps1"
. "C:\arashms\Hackaton Search\ARM_template\Recreate_VM.ps1"

Select-AzureRmSubscription -SubscriptionId "e9aac0f0-83bd-43cf-ab35-c8e3eccc8932"



# README 
# you need to create a TARGET RESOURCE GROUP AND STORAGE ACCOUNT AND CONTAINER "vhd" first
# then put the names in the variables below --->



### THIS IS THE SOURCE SPECIALIZED IMAGE ->
 
### Defines the SOURCE Storage Account
$sourceStorageAccountName = "devbaseimagediag724"
$sourceStorageKey = "iJIlDUyaS2fD47AMjmtMDLcLqVJwhUIwWNQO4KfrMZa+/t/XKTybbtksEUqt/8m0VDgLFnYzPpuAGn+qsia7AQ=="
$sourceBlob = "b24eef1b7fe89420188f33a3e8470bed8.vhd"
$sourceContainer = "vhd8f6c2519f76f48bd86ca4b3436ef4d59"

### Defines the location of the VHD we want to copy
$sourceVhdUri = "https://" + $sourceStorageAccountName + ".blob.core.windows.net/" + $sourceContainer + "/" + $sourceBlob  


### <------ 

 
### Defines the DESTINATION Storage Account
$destinationResourceGroup = "StudentGeneralizedVM"

$destStorageAccountName = "studentvmgen"
$destStorageKey = "YtLwVf8GyRuTjzbBOG6dDauR75C5SwdAp8DGVHZWb8uovPkyxf22ypJ5r6YWqLCULy4vAxfpCdE+Ap8WwT0ECQ=="
$destinationBlob = "student_tobe_genarlized.vhd" 
$destContainer = "vhds"

#<----




"Start Copy"

CopyBlob $sourceVhdUri $sourceStorageAccountName $sourceStorageKey $sourceBlob $sourceContainer $destStorageAccountName $destStorageKey $destContainer $destinationBlob

"Copy Done"

"Start Re-create VM"

$subnetName = "mySubNet"
$location = "West Europe"
$vnetName = "devVnet"
$ipName = "devPIP"
$nicName = "devNic"
$nsgName = "devNsg"
$vmName = "devVM"
$osDiskUri =  "https://" + $destStorageAccountName + ".blob.core.windows.net/" + $destContainer + "/" + $destinationBlob  
$vmSize = "Standard_DS2_v2"


ReCreateVM $destinationResourceGroup $subnetName $location $vnetName $ipName $nicName $nsgName $vmName $osDiskUri $vmSize 



