# Login with to Azure with the following command: az login

# This file is bespoke to UoG and is not intended to be used by any other organisation
# The following variables should be replaced with the correct values for the organisation. The following variables are:

# Make sure to configure with the correct details if already existing

$rgName = "ubiq_server-rg"
$location = "ukwest"
$vmName = "ubiqServerVm"
$adminUsername = "azureuser"
$adminPassword = "Peggy!Rice?123"
$image = "MicrosoftWindowsServer:WindowsServer:2022-datacenter-azure-edition-core:latest"
$displayName = "imUbiqServer"
$nsgName = "ubiqServerVmNSG"

# Create a resource group - if a resource group already exists, comment out the following line:
az group create --name $rgName --location $location


# If you want to reuse the same public IP address, you can add the following flag to the az vm create command:
# --public-ip-address "<public-ip-address>"
# If you do not have a public IP address, you can create one with the following command:
# az network public-ip create --resource-group <resource-group-name> --name <public-ip-address-name> --sku Standard --allocation-method Static

# THE AZURE FOR STUDENTS SUBSCRIPTION LIMITS THE NUMBER OF IP ADDRESSES THAT YOU CAN CREATE

az vm create \
  --resource-group $rgName \
  --name $vmName \
  --image $image \
  --public-ip-address "20.254.255.206" \
  --admin-username azureuser \
  --admin-password Peggy!Rice?123 \
  --generate-ssh-keys 

serverIp=$(az vm show -d -g $rgName -n $vmName --query publicIps -o tsv)

ssh-keygen -R $serverIp

# set arbitrary rule name
$ruleName = "Allow22"

az network nsg rule create \
  --resource-group $rgName \
  --nsg-name $nsgName \
  --name $ruleName \
  --direction Inbound \
  --protocol Tcp \
  --destination-port-range 22 \
  --access Allow \
  --priority 101


# after this point the way that the server has been built has not been automated
# the next steps are to be done manually
# open the azure portal
# navigate to the virtual machine you have just created
# click on the connect button
# follow the instructions to connect to the server - this will require you to download an RDP file
# once connected to the server, open a powershell terminal
# run the following commands to install git, nodejs, npm and openssl

# <withoutPermissions.sh>


# For the next steps to execute correctly, ensure you have created a service principal with the following command:
#     az ad sp create-for-rbac --name <YourServicePrincipalName> --role Contributor --scopes /subscriptions/<YourSubscriptionId>

# The output of the command will be similar to the following:
#     { 
#       "appId": "<service_principal_app_id>",
#       "displayName": "<YourServicePrincipalName>",
#       "name": "http://<YourServicePrincipalName>",
#       "password": "<service_principal_password>",
#       "tenant": "<service_principal_tenant_id>"
#     }

# to execute the following commands, it is required that the logged in account has Application.ReadWrite.All permission

# THIS PART IS FOR WHEN I HAVE THE PERMISSIONS FROM AZURE / JULIE

# ssh azureuser@$serverIp

# mkdir ~/.azure
# touch ~/.azure/credentials

# # If you want to create a credentials.txt file manually the information this is required is the subscription_id, client_id, secret and tenant
# # The following is an example of the content of the credentials.txt file being created automatically via the Azure CLI to enable one click automation

# # This can be used to get the IDs of relevant resources:
# # az ad sp list --display-name "imUbiqServer" --query "[].{Name:displayName, AppId:appId, ObjectId:id}" -o table 

# # If you do not have the service principal password, you must regenerate the credentials with the following command:
# #     az ad sp credential reset --name <YourServicePrincipalName> --credential-description <YourDescription> --end-date <YourEndDate> --password <YourPassword>

# subscription_id=$(az account show | jq -r '.id')
# client_id=$(az ad sp show --id $(az ad sp list --display-name "imUbiqServer" --query "[].id" --output tsv) --query "appId" -o tsv)


# cat <<EOF > azure_credentials.txt
# [default]
# subscription_id = $subscription_id
# client_id= $client_id
# secret=<service_principal_password>
# tenant=<service_principal_tenant_id>
# EOF

# RETURN TO THIS WHEN I HAVE THE PERMISSIONS FROM AZURE / JULIE
