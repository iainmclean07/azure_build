# Login with to Azure with the following command: az login

# This file is bespoke to UoG and is not intended to be used by any other organisation
# The following variables should be replaced with the correct values for the organisation. The following variables are:

# Make sure to configure with the correct details if already existing

# Location will depend on resource group location

printf "\n\nCreating Azure VM...\n\n"

rg_name="RG-UKS_Prod-CoSE-FUSION"
location="uksouth"
vm_name="vm-xrlab-test-001"
admin_username="azureuser"
admin_password="Peggy!Rice?123"
image="Canonical:ubuntu-24_04-lts:server:latest"
display_name="vm-xrlab-test-001"
nsg_name="nsg-allowUbiq-001"
pip_name="pip-xrlab-test-ukwest-001"
rule_name="Allow-8009-8011"
dns_name="xrlab-test-ukwest-001"

printf "\nServer name: $vm_name \nImage: $image \n\n"

# Create a resource group - if a resource group already exists, this will return the details of the group
az group create --name $rg_name --location $location


# If you want to reuse the same public IP address, you can add the following flag to the az vm create command:
# --public-ip-address "<public-ip-address>"
# If you do not have a public IP address, you can create one with the following command:

pips=$(az network public-ip create --resource-group $rg_name --name $pip_name --sku Standard --allocation-method Static --query "publicIp.id" -o tsv)

az network public-ip update --resource-group $rg_name --name $pip_name --dns-name "$dns_name" 

printf "\n\nPublic IP: $pips \n"

# THE AZURE FOR STUDENTS SUBSCRIPTION LIMITS THE NUMBER OF IP ADDRESSES THAT YOU CAN CREATE

az vm create \
  --resource-group $rg_name \
  --name $vm_name \
  --image $image \
  --public-ip-address $pips \
  --admin-username $admin_username \
  --admin-password $admin_password \
  --generate-ssh-keys 

printf "\n\nVM created successfully\n"

serverIp=$(az vm show -d -g $rg_name -n $vm_name --query $pips -o tsv)

serverIp=$(az vm show -d -g $rg_name -n $vm_name --query publicIps -o tsv)

if [[ -z "$serverIp" ]]; then
  echo "❌ Error: serverIp is null or empty. Exiting."
  exit 1
fi

ssh-keygen -R $serverIp

printf "\n\nSSH key generated\n"


# Get NIC ID (cleanly)
nic_id=$(az vm nic list -g $rg_name --vm-name $vm_name --query "[0].id" -o tsv)
printf "\nNIC ID: $nic_id"

# Get Subnet ID (cleanly)
snet_id=$(az network nic show --ids "$nic_id" --query "ipConfigurations[0].subnet.id" -o tsv)
printf "\nSubnet ID: $snet_id"

az network vnet subnet update \
  --resource-group "$rg_name" \
  --vnet-name "${vm_name}VNET" \
  --name "${vm_name}Subnet" \
  --network-security-group "${vm_name}NSG" \

# Get NSG ID (cleanly)
nsg_id=$(az network vnet subnet show --ids "$snet_id" --query "networkSecurityGroup.id" -o tsv)
printf "\nNSG ID: $nsg_id"

# Extract NSG Name from the full ID
nsg_name=$(basename "$nsg_id")
printf "\nNSG Name: $nsg_name"

# Create NSG rule
az network nsg rule create \
  --resource-group "$rg_name" \
  --nsg-name "$nsg_name" \
  --name "$rule_name" \
  --direction Inbound \
  --protocol Tcp \
  --destination-port-range 8009-8011 \
  --access Allow \
  --priority 101

printf "\n\nNetwork security group rule created\n"

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
#       "display_name": "<YourServicePrincipalName>",
#       "name": "http://<YourServicePrincipalName>",
#       "password": "<service_principal_password>",
#       "tenant": "<service_principal_tenant_id>"
#     }

# to execute the following commands, it is required that the logged in account has Application.ReadWrite.All permission

# THIS PART IS FOR WHEN I HAVE THE PERMISSIONS FROM AZURE / JULIE

ssh azureuser@$serverIp << EOF
  sudo apt-get update
  sudo apt-get install -y git
  curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash - 
  sudo apt-get install -y nodejs
  sudo apt-get install -y npm
  sudo apt-get install -y openssl
  git clone https://github.com/UCL-VR/ubiq.git
  cd ./ubiq/Node
  openssl req -nodes -new -x509 -keyout key.pem -out cert.pem -subj "/C=GB/ST=Scotland/L=Glasgow/O=UoG/OU=Fusion/CN=fusionServer"
  npm install 
  npm audit fix
  npm start
  echo "Server running on port 8009 - 8011"
EOF

printf "\n\nServer setup complete\n"

# ANSIBLE SETUP

# mkdir ~/.azure
# touch ~/.azure/credentials

# # If you want to create a credentials.txt file manually the information this is required is the subscription_id, client_id, secret and tenant
# # The following is an example of the content of the credentials.txt file being created automatically via the Azure CLI to enable one click automation

# # This can be used to get the IDs of relevant resources:
# # az ad sp list --display-name "imUbiqServer" --query "[].{Name:display_name, AppId:appId, ObjectId:id}" -o table 

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
