. "C:\arashms\Hackaton Search\ARM_template\Copy_VHD_Between_subs.ps1"

#Login-AzureRmAccount



# Backup the BaseDevImage VHD


### THIS IS THE SOURCE SPECIALIZED IMAGE ->

### Defines the location of the VHD we want to copy
$sourceVhdUri = "https://devbaseimagediag724.blob.core.windows.net/vhd8f6c2519f76f48bd86ca4b3436ef4d59/b24eef1b7fe89420188f33a3e8470bed8.vhd"
 
### Defines the source Storage Account
$sourceStorageAccountName = "labdisk"
$sourceStorageKey = "yZQuVwN9ZKW0qI8FsWKSXBzDzMuEvqmZcFYKBUFH9+IL8pXiZpuNQhwDglSLYmEuRbs5+35EQkhDpNYKaFqpsw=="
$sourceBlob = "devMachine20170831_Specialized_LogicApps.vhd"
$sourceContainer = "vhds"

### <------ 

 
### Defines the target Storage Account

$destStorageAccountName = "labdisk"
$destStorageKey = "yZQuVwN9ZKW0qI8FsWKSXBzDzMuEvqmZcFYKBUFH9+IL8pXiZpuNQhwDglSLYmEuRbs5+35EQkhDpNYKaFqpsw=="
$destinationBlob = "devMachine20170831_GENERALIZED_LogicApps.vhd" 
$destContainer = "vhds"

#<----



"Start Copy"

CopyBlob $sourceVhdUri $sourceStorageAccountName $sourceStorageKey $sourceBlob $sourceContainer $destStorageAccountName $destStorageKey  $destContainer $destinationBlob

"Copy Done"

