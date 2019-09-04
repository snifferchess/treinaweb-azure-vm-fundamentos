#!/usr/bin/env sh

set -x

vmLocalAdminUser="azureuser"
locationName="westus"
resourceGroupName="azure-vm-fundamentos"
vmName="linux-vm"
vmSize="Standard_B1s"

networkName="vnet"
subnetName="default"
subnetAddressPrefix="10.0.0.0/24"
vnetAddressPrefix="10.0.0.0/16"

nicName="linux-vm-nic"
publicIPAddressName="linux-vm-ip"
dnsNameLabel="linux-vm-uniquednsname" # linux-vm-uniquednsname.westus.cloudapp.azure.com

# Create a resource group.
az group create --name $resourceGroupName --location $locationName

# Create a virtual network.
az network vnet create --resource-group $resourceGroupName \
  --name $networkName --address-prefix $vnetAddressPrefix \
  --subnet-name $subnetName --subnet-prefix $subnetAddressPrefix

# Create a public IP address.
az network public-ip create --resource-group $resourceGroupName \
  --name $publicIPAddressName \
  --dns-name $dnsNameLabel

# Create a virtual network card and associate with public IP address and NSG.
az network nic create \
  --resource-group $resourceGroupName \
  --name $nicName \
  --vnet-name $networkName \
  --subnet $subnetName \
  --public-ip-address $publicIPAddressName

# Create a new virtual machine, this creates SSH keys if not present.
az vm create --resource-group $resourceGroupName \
  --name $vmName \
  --nics $nicName \
  --size $vmSize \
  --admin-username $vmLocalAdminUser \
  --image UbuntuLTS \
  --generate-ssh-keys \
  --verbose

# Open port 22 to allow SSh traffic to host.
az vm open-port --port 22 --resource-group $resourceGroupName --name $vmName
