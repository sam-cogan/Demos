#Requires -Modules Pester
<#
.SYNOPSIS
    Tests a specific ARM template
.EXAMPLE
    Invoke-Pester 
.NOTES
    This file has been created as an example of using Pester to evaluate ARM templates
    Source: https://github.com/Azure/azure-quickstart-templates/tree/master/201-vmss-automation-dsc
#>

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$template = Split-Path -Leaf $here



$TempValidationRG = "Pester-Validation-RG"
$location = "West Europe"





Describe "Template: $template" -Tags Unit {
     BeforeAll {
         New-AzureRmResourceGroup -Name $TempValidationRG -Location $Location
    }

    
    Context "Template Syntax" {
        
        It "Has a JSON template" {        
            "$here\azuredeploy.json" | Should Exist
        }
        
        It "Has a parameters file" {        
            "$here\azuredeploy.parameters.json" | Should Exist
        }
        
        It "Has a metadata file" {        
            "$here\metadata.json" | Should Exist
        }

        It "Converts from JSON and has the expected properties" {
            $expectedProperties = '$schema',
            'contentVersion',
            'parameters',
            'variables',
            'resources',                                
            'outputs'
            $templateProperties = (get-content "$here\azuredeploy.json" | ConvertFrom-Json -ErrorAction SilentlyContinue) | Get-Member -MemberType NoteProperty | % Name
            $templateProperties | Should Be $expectedProperties
        }
        
        It "Creates the expected Azure resources" {
            $expectedResources = 'Microsoft.Storage/storageAccounts',
            'Microsoft.Network/virtualNetworks',
            'Microsoft.Network/publicIPAddresses',
            'Microsoft.Network/loadBalancers',
            $templateResources = (get-content "$here\azuredeploy.json" | ConvertFrom-Json -ErrorAction SilentlyContinue).Resources.type
            $templateResources | Should Be $expectedResources
        }
        


    }
    
    Context "Template Validation" {
          
        It "Template $here\azuredeploy.json and parameter file  passes validation" {
      
            # Complete mode - will deploy everything in the template from scratch. If the resource group already contains things (or even items that are not in the template) they will be deleted first.
            # If it passes validation no output is returned, hence we test for NullOrEmpty
            $ValidationResult = Test-AzureRmResourceGroupDeployment -ResourceGroupName $TempValidationRG -Mode Complete -TemplateFile "$here\azuredeploy.json" -TemplateParameterFile "$here\azuredeploy.parameters.json"
            $ValidationResult | Should BeNullOrEmpty
        }
    }

     AfterAll {
         Remove-AzureRmResourceGroup $TempValidationRG -Force
     }
}
