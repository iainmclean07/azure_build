rgGroupName="ubiq_server-rg"
vmName="fusionServerVm-dev-v0.1"

# Get the public IP address name associated with the VM
ipName=$(az vm show --resource-group $rgGroupName --name $vmName --query "networkProfile.networkInterfaces[0].id" -o tsv | xargs -I {} az network nic show --resource-group $rgGroupName --ids {} --query "ipConfigurations[0].publicIpAddress.id" -o tsv | xargs -I {} basename {})

# Delete public IP addresses may require elevated permissions
# az network public-ip delete --resource-group <resourceGroupName> --name fusionServerVmPublicIP


# Delete the public IP address if it exists
if [ -n "$ipName" ]; then
  az network public-ip delete --resource-group $rgGroupName --name $ipName
fi

az vm stop --resource-group $rgGroupName --name $vmName
az vm deallocate --resource-group $rgGroupName --name $vmName
az vm delete --resource-group $rgGroupName --name $vmName --force-deletion none

