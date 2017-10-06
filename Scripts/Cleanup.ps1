Select-AzureRmSubscription -SubscriptionId 469048f1-92af-4c71-a63b-330ec31d2b82
Remove-AzureRmResourceGroup  -Name "crossSubscriptionDeployment" -Force
Remove-AzureRmResourceGroup  -Name "functionsDeployment"  -Force
Remove-AzureRmResourceGroup -Name "conditionalDeployment"  -Force
Remove-AzureRmResourceGroup -Name "NestedNewOrExistingDeployment"  -Force


###second Sub
Select-AzureRmSubscription -SubscriptionId 9ed15c9b-3740-4e5f-ac3d-52fbc1dd5a8c
Remove-AzureRmResourceGroup  -Name "crossSubscriptionDeployment" -Force