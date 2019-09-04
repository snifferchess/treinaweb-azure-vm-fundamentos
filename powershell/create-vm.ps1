#!/usr/bin/env pwsh

Set-PSDebug -Trace 1

$vmLocalAdminUser = "azureuser"
$vmLocalAdminSecurePassword = ConvertTo-SecureString "Q#UupAnPd!tn+4YY" -AsPlainText -Force
$locationName = "westus"
$resourceGroupName = "azure-vm-fundamentos"
$computerName = "win-vm"
$vmName = "win-vm"
$vmSize = "Standard_B1s"

$networkName = "vnet"
$subnetName = "default"
$subnetAddressPrefix = "10.0.0.0/24"
$vnetAddressPrefix = "10.0.0.0/16"

$nicName = "win-vm-nic"
$publicIPAddressName = "win-vm-ip"
$dnsNameLabel = "win-vm-uniquednsname" # win-vm-uniquednsname.westus.cloudapp.azure.com

# Create a resource group
New-AzResourceGroup -Name $resourceGroupName -Location $locationName

# Create network configuration
$singleSubnet = New-AzVirtualNetworkSubnetConfig -Name $subnetName -AddressPrefix $subnetAddressPrefix
$vnet = New-AzVirtualNetwork -Name $networkName -ResourceGroupName $resourceGroupName -Location $locationName -AddressPrefix $vnetAddressPrefix -Subnet $singleSubnet
$publicIp = New-AzPublicIpAddress -Name $publicIPAddressName -DomainNameLabel $dnsNameLabel -ResourceGroupName $resourceGroupName -Location $locationName -AllocationMethod "Dynamic"

# Create a network security group
$nsgRuleRDP = New-AzNetworkSecurityRuleConfig -Name "nsgRDP" -Protocol "Tcp" -Direction "Inbound" -Priority 1000 -SourceAddressPrefix "*" -SourcePortRange "*" -DestinationAddressPrefix "*" -DestinationPortRange 3389 -Access "Allow"
$nsg = New-AzNetworkSecurityGroup -ResourceGroupName $resourceGroupName -Location $locationName -Name "win-vm-nsg" -SecurityRules $nsgRuleRDP

# Create a virtual network card and associate with public IP address and NSG
$nic = New-AzNetworkInterface -Name $nicName -ResourceGroupName $resourceGroupName -Location $locationName -SubnetId $vnet.Subnets[0].Id -PublicIpAddressId $publicIp.Id -NetworkSecurityGroupId $nsg.Id

# Create credential object
$credential = New-Object System.Management.Automation.PSCredential ($vmLocalAdminUser, $vmLocalAdminSecurePassword);

# Create a virtual machine configuration
$virtualMachine = New-AzVMConfig -VMName $vmName -VMSize $vmSize
$virtualMachine = Set-AzVMOperatingSystem -VM $virtualMachine -Windows -ComputerName $computerName -Credential $credential -ProvisionVMAgent -EnableAutoUpdate
$virtualMachine = Set-AzVMSourceImage -VM $virtualMachine -PublisherName "MicrosoftWindowsServer" -Offer "WindowsServer" -Skus "2019-Datacenter" -Version latest
$virtualMachine = Add-AzVMNetworkInterface -VM $virtualMachine -Id $nic.Id

# Create a virtual machine
New-AzVM -ResourceGroupName $resourceGroupName -Location $locationName -VM $virtualMachine -Verbose

Set-PSDebug -Off
