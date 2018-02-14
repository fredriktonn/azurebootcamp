function CopyBlob(
$sourceVhdUri,
$sourceStorageAccountName,
$sourceStorageKey,
$sourceBlob,
$sourceContainer,
$destStorageAccountName,
$destStorageKey,
$destContainer,
$destinationBlob
)
{
  

### Create a context for the source storage account
$sourceContext = New-AzureStorageContext  –StorageAccountName $sourceStorageAccountName `
                                        -StorageAccountKey $sourceStorageKey  
 
### Create a context for the target storage account
$destContext = New-AzureStorageContext  –StorageAccountName $destStorageAccountName `
                                        -StorageAccountKey $destStorageKey  

 
### Start the async copy operation
$blob1 = Start-AzureStorageBlobCopy -SrcBlob $sourceBlob -SrcContainer $sourceContainer -SrcContext $sourceContext -DestContainer $destContainer -DestBlob $destinationBlob -DestContext $destContext
 
### Get the status of the copy operation
$status = $blob1 | Get-AzureStorageBlobCopyState 
 
### Output the status every 10 seconds until it is finished                                    
While($status.Status -eq "Pending"){
  $status = $blob1 | Get-AzureStorageBlobCopyState 
  Start-Sleep 10
  $status
}

}