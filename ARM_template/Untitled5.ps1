### This assumes you have already imported the azure publishsettings file and the subscriptions are known on your machine.
Select-AzureSubscription "MyCoolSubscriptionName" 
 
### Defines the location of the VHD we want to copy
$sourceVhdUri = "https://mysourcestorageaccountname.blob.core.windows.net/omitted_part_of_the_uri/AX2012R3_DEMO_OS.vhd"
 
### Defines the source Storage Account
$sourceStorageAccountName = "mysourcestorageaccountname"
$sourceStorageKey = "mywaytolongsourcestoragekey"
 
### Defines the target Storage Account
$destStorageAccountName = "mytargetstorageaccountname"
$destStorageKey = "myalsowaytolongtargetstoragekey"
 
### Create a context for the source storage account
$sourceContext = New-AzureStorageContext  –StorageAccountName $sourceStorageAccountName `
                                        -StorageAccountKey $sourceStorageKey  
 
### Create a context for the target storage account
$destContext = New-AzureStorageContext  –StorageAccountName $destStorageAccountName `
                                        -StorageAccountKey $destStorageKey  
 
### Name for the destination storage container
$containerName = "dynamicsDeployments"
 
### Create a new container in the destination storage
New-AzureStorageContainer -Name $containerName -Context $destContext 
 
### Start the async copy operation
$blob1 = Start-AzureStorageBlobCopy -srcUri $srcUri `
                                    -SrcContext $srcContext `
                                    -DestContainer $containerName `
                                    -DestBlob "AX2012R3_DEMO_OS.vhd" `
                                    -DestContext $destContext
 
### Get the status of the copy operation
$status = $blob1 | Get-AzureStorageBlobCopyState 
 
### Output the status every 10 seconds until it is finished                                    
While($status.Status -eq "Pending"){
  $status = $blob1 | Get-AzureStorageBlobCopyState 
  Start-Sleep 10
  $status
}