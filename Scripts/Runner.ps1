####Functions#####
Select-AzureRmSubscription -SubscriptionId 469048f1-92af-4c71-a63b-330ec31d2b82 
New-AzureRmResourceGroup -Name "functionsDeployment" -Location "West Europe" -Force
New-AzureRmResourceGroupDeployment -Name "functionsDemo" -ResourceGroupName "functionsDeployment" -TemplateFile ".\functions\functions.json" -TemplateParameterFile ".\functions\functions.params.json" 

#####Cros Sub Demo####
Select-AzureRmSubscription -SubscriptionId 469048f1-92af-4c71-a63b-330ec31d2b82
New-AzureRmResourceGroup -Name "crossSubscriptionDeployment" -Location "eastus2" 
Select-AzureRmSubscription -SubscriptionId 9ed15c9b-3740-4e5f-ac3d-52fbc1dd5a8c
New-AzureRmResourceGroup -Name "crossSubscriptionDeployment" -Location "eastus2" 

New-AzureRmResourceGroupDeployment -Name "CrossSubDemo" -ResourceGroupName "crossSubscriptionDeployment" -TemplateFile ".\NestedTemplates\CrossSubscriptionDeployments.json" -TemplateParameterFile ".\NestedTemplates\CrossSubscriptionDeployments.parameters.json" 

####If and Conditions

Select-AzureRmSubscription -SubscriptionId 469048f1-92af-4c71-a63b-330ec31d2b82 
New-AzureRmResourceGroup -Name "conditionalDeployment" -Location "West Europe" -Force
New-AzureRmResourceGroupDeployment -Name "conditionalDemo" -ResourceGroupName "conditionalDeployment" -TemplateFile ".\if\if.json" -TemplateParameterFile ".\if\if.params.json" 

#####NestedNewOrExisting

Select-AzureRmSubscription -SubscriptionId 469048f1-92af-4c71-a63b-330ec31d2b82 
New-AzureRmResourceGroup -Name "NestedNewOrExistingDeployment" -Location "West Europe" -Force
$nestedResult=New-AzureRmResourceGroupDeployment -Name "NestedNewOrExistingDemo" -ResourceGroupName "NestedNewOrExistingDeployment" -TemplateFile ".\NestedTemplates\NestedNewOrExisting.json" -TemplateParameterFile ".\NestedTemplates\NestedNewOrExisting.params.json" 


##Tests###

..\testing\azuredeploy.tests.ps1