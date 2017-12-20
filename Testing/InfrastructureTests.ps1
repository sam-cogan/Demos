$resourceGroup = "InfrastructureTesting"

Describe "Resource Group tests" -tag "AzureInfrastructure" {
    
    Context "Resource Groups" {
        It "Check Main Resource Group $resourceGroup Exists" {
            Get-AzureRmResourceGroup -Name $resourceGroup -ErrorAction SilentlyContinue | Should Not be $null
        }
   
    }
}

Describe "Networking Tests" -tag "AzureInfrastructure" {
    Context "Networking" {
        $vNet=Get-AzureRmVirtualNetwork -Name "$resourceGroup-vNet" -ResourceGroupName $resourceGroup -ErrorAction SilentlyContinue

        it "Check Virtual Network $resourceGroup-vNet Exists" {
            $vNet | Should Not be $null
        }
            
        it "Subnet $resourceGroup-subnet1 Should Exist" {
            $subnet = Get-AzureRmVirtualNetworkSubnetConfig -Name "$resourceGroup-subnet1" -VirtualNetwork $vNet -ErrorAction SilentlyContinue
            $subnet| Should Not be $null
        }
        
        it "Subnet $resourceGroup-subnet1 Should have Address Range 10.2.0.0/24" {
            $subnet = Get-AzureRmVirtualNetworkSubnetConfig -Name "$resourceGroup-subnet1" -VirtualNetwork $vNet -ErrorAction SilentlyContinue
            $subnet.AddressPrefix | Should be "10.2.0.0/24"
        }
         
    }
}


Describe "Virtual Machine Tests" -tag "AzureInfrastructure"{
    context "VM Tests"{
        $vmName="InfraTest-Vm1"
        $vm= Get-AzureRmVM -Name $vmName -ResourceGroupName $resourceGroup
    
        it "Virtual Machine $vmName Should Exist" {
            $vm| Should Not be $null
        }

        it "Virtual Machine $vmName Should Be Size Standard_DS1_v2" {
            $vm.HardwareProfile.VmSize | should be "Standard_DS1_v2"
        }

        it "Virtual Machine $vmName Should Be Located in West Europe" {
            $vm.Location | should be "westeurope"
        }

    }
           
}
