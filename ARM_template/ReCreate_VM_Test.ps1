. "C:\arashms\Hackaton Search\ARM_template\Recreate_VM.ps1"

Select-AzureRmSubscription -SubscriptionId "e9aac0f0-83bd-43cf-ab35-c8e3eccc8932"

$destinationResourceGroup = "DevBaseVM"

$subnetName = "devSubNet"
$location = "West Europe"
$vnetName = "devVnet"
$ipName = "devPIP"
$nicName = "devNic"
$nsgName = "devNsg"
$vmName = "devVM"
$osDiskUri =  "https://devbaseimagedisks222.blob.core.windows.net/vhds/baseDev20170830181015.vhd"
$vmSize = "Standard_DS2_v2"

ReCreateVM $destinationResourceGroup $subnetName $location $vnetName $ipName $nicName $nsgName $vmName $osDiskUri $vmSize 