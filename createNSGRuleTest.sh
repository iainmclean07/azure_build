# Set variables
rgName="RG-UKS_Prod-CoSE-FUSION"
vmName="vm-xrlab-test-001"
ruleName="Allow-8009-8011"

# Get NIC ID (cleanly)
nic_id=$(az vm nic list -g $rgName --vm-name $vmName --query "[0].id" -o tsv)
printf -e "\nNIC ID: $nic_id"

# Get Subnet ID (cleanly)
snet_id=$(az network nic show --ids "$nic_id" --query "ipConfigurations[0].subnet.id" -o tsv)
printf "\nSubnet ID: $snet_id"

az network vnet subnet update \
  --resource-group "$rgName" \
  --vnet-name "${vmName}VNET" \
  --name "${vmName}Subnet" \
  --network-security-group "${vmName}NSG" \

# Get NSG ID (cleanly)
nsg_id=$(az network vnet subnet show --ids "$snet_id" --query "networkSecurityGroup.id" -o tsv)
printf "\nNSG ID: $nsg_id"

# Extract NSG Name from the full ID
nsg_name=$(basename "$nsg_id")
printf "\nNSG Name: $nsg_name"

# Create NSG rule
az network nsg rule create \
  --resource-group "$rgName" \
  --nsg-name "$nsg_name" \
  --name "$ruleName" \
  --direction Inbound \
  --protocol Tcp \
  --destination-port-range 8009-8011 \
  --access Allow \
  --priority 101
