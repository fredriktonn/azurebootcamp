

$subscriptionId = "e9aac0f0-83bd-43cf-ab35-c8e3eccc8932"
$rgName = "AZBC2"
$snapshotName = "devazbc-image-20170828184618"
$imageName = ""


Login-AzureRmAccount
Select-AzureRmSubscription -SubscriptionId $subscriptionId

$snapshot = Get-AzureRmSnapshot -ResourceGroupName $rgName -SnapshotName $snapshotName




Install-Module AzureRM.Compute,AzureRM.Network

$image = Get-AzureRMImage -ImageName $imageName -ResourceGroupName $rgName


