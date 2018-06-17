# 06/13/2018  
# This script drops the resource group and creates a new one
# Todo: create a template and use Save-AzureRmResourceGroupDeploymentTemplate 
#       HDInsight clusters cannot be exported yet 
# Todo: format per best practices - https://github.com/PoshCode/PowerShellPracticeAndStyle

Import-Module .\azure-ps-helpers.psm1


$configJson = Join-Path -Path $PSScriptRoot -ChildPath "cluster_config.json"
$configParams= Get-Content -Raw -Path $configJson | ConvertFrom-Json
$clusterName=$configParams.clusterName
$resourceGroupName="$($configParams.clusterName)-rg"
$storageAccountName= "storage$(Get-UniqueString -id $clusterName)"
$storageContainerName= "container$(Get-UniqueString -id $clusterName)"
$location = $configParams.location

Write-Host("DROPPING AND CREATING RESOURCE GROUP - $($resourceGroupName). PLEASE WAIT...")
$rg=Get-AzureRmResourceGroup -Name $resourceGroupName -ErrorAction SilentlyContinue
if ($rg -ne $null){
    Remove-AzureRmResourceGroup -Name $resourceGroupName -Force
}
New-AzureRmResourceGroup -Name $resourceGroupName -Location $location 


Write-Host("CREATING STORAGE ACCOUNT. PLEASE WAIT...") 
New-AzureRmStorageAccount `
    -ResourceGroupName $resourceGroupName `
    -Name $storageAccountName `
    -Location $location `
    -SkuName Standard_GRS `
    -Kind Storage


Write-Host("CREATING CONTAINER...") 
$storageAccountKey=(Get-AzureRmStorageAccountKey -ResourceGroupName $resourceGroupName -AccountName $storageAccountName)[0].Value
$storageContext = New-AzureStorageContext -StorageAccountName $storageAccountName -StorageAccountKey $storageAccountKey
$storageContainer=New-AzureStorageContainer -Name $storageContainerName -Context $storageContext -Permission Off



Write-Host("CREATING HTTP/SSH CREDENTIAL...") 
$pwd = ConvertTo-SecureString $configParams.clusterPassword -AsPlainText -Force
$httpCredential = New-Object System.Management.Automation.PSCredential ($configParams.clusterUserName, $pwd)
$sshCredential = New-Object System.Management.Automation.PSCredential ($configParams.sshUserName, $pwd)
 


Write-Host("CREATING CLUSTER. PLEASE WAIT...")
# 1. Cluster Name -> 2. Subscription -> 3. Cluster login name -> 4. Cluster password
# 5. sshusername -> 6. Resource Group Name -> 7. Cluster type -> 8. OS -> Version
New-AzureRmHDInsightCluster `
    -Location $location `
    -ResourceGroupName $resourceGroupName `
    -ClusterName $clusterName `
    -ClusterSizeInNodes $configParams.clusterSizeInNodes `
    -ClusterType Hadoop `
    -OSType Linux `
    -Version 3.5 `
    -HttpCredential $httpCredential `
    -SshCredential $sshCredential `
    -DefaultStorageAccountName $storageAccountName `
    -DefaultStorageAccountKey $storageAccountKey `
    -DefaultStorageContainer $storageContainerName   