. "C:\arashms\Hackaton Search\ARM_template\Copy_VHD_Between_subs.ps1"

#Login-AzureRmAccount

#Select-AzureRmSubscription -SubscriptionId "e9aac0f0-83bd-43cf-ab35-c8e3eccc8932"

# Backup the BaseDevImage VHD

### Defines the target Storage Account

$destStorageAccountName = "labdisk"
$destStorageKey = "yZQuVwN9ZKW0qI8FsWKSXBzDzMuEvqmZcFYKBUFH9+IL8pXiZpuNQhwDglSLYmEuRbs5+35EQkhDpNYKaFqpsw=="
$destinationBlob = "hackatonImage170831_v3.vhd" 
$destContainer = "vhds"

#<----



### THIS IS THE SOURCE SPECIALIZED IMAGE ->

### Defines the location of the VHD we want to copy
$sourceVhdUri = "https://labdisk.blob.core.windows.net/vhds/devMachineBackup20170831Specialized.vhd"
 
### Defines the source Storage Account
$sourceStorageAccountName = "labdisk"
$sourceStorageKey = "yZQuVwN9ZKW0qI8FsWKSXBzDzMuEvqmZcFYKBUFH9+IL8pXiZpuNQhwDglSLYmEuRbs5+35EQkhDpNYKaFqpsw=="
$sourceBlob = "hackaton170831_v3.vhd"
$sourceContainer = "vhds"

### <------ 

 



"Start Copy"

CopyBlob $sourceVhdUri $sourceStorageAccountName $sourceStorageKey $sourceBlob $sourceContainer $destStorageAccountName $destStorageKey  $destContainer $destinationBlob

"Copy Done"
