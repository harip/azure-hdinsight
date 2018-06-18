import azure.mgmt.storage as st 
import azure.common.credentials as creds

az_cred=creds.get_cli_profile()
print(az_cred)
