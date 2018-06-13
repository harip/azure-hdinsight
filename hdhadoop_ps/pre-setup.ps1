# Get all subscriptions
Get-AzureRmSubscription

# If subscription id does not match
Set-AzureRmContext -SubscriptionId "xxxxxxxxx-xxxx-..."

# Save the file
Save-AzureRmProfile -Path “C:\azureprofile.json”

Import-AzureRmContext -path “C:\azureprofile.json”