# Original version - edX-Microsoft: DAT202.1x
# https://courses.edx.org/courses/course-v1:Microsoft+DAT202.1x+1T2018a

$configJson = Join-Path -Path $PSScriptRoot -ChildPath "cluster_config.json"
$configParams= Get-Content -Raw -Path $configJson | ConvertFrom-Json
$resourceGroup="$($configParams.clusterName)-rg"

# Get resource group
$rg=Get-AzureRmResourceGroup -Name $resourceGroup -ErrorAction SilentlyContinue

# If resource group does not exist create rg
if ($rg -eq $null){
    Write-Host("create rg")
}