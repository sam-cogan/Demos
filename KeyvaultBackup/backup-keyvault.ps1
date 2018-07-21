[CmdletBinding()]
Param(

    [Parameter(Mandatory = $True)]
    [string]$keyvaultName,
	
    [Parameter(Mandatory = $True)]
    [string]$keyVaultResourceGroup,


    [Parameter(Mandatory = $True)]
    [string]$storageAccountName,
   

    [Parameter(Mandatory = $True)]
    [string]$storageResourceGroup,

   
    [Parameter(Mandatory = $True)]
    [string]$fileshareName,

   
    [string]$backupFolder = "$env:Temp\KeyVaultBackup"

   
)


#######Setup backup directory


If ((test-path $backupFolder)) {
    Remove-Item $backupFolder -Recurse -Force

}

####### Backup items

New-Item -ItemType Directory -Force -Path $backupFolder | Out-Null

Write-Output "Starting backup of KeyVault to local directory"
###Certificates

$certificates = Get-AzureKeyVaultCertificate -VaultName $keyvaultName 

foreach ($cert in $certificates) {
    Backup-AzureKeyVaultCertificate -Name $cert.name -VaultName $keyvaultName -OutputFile "$backupFolder\certificate-$($cert.name)" | Out-Null
}

###Secrets
$secrets = Get-AzureKeyVaultSecret -VaultName $keyvaultName

foreach ($secret in $secrets) {
    #Exclude any secerets automatically generated when creating a cert, as these cannot be backed up   
    if (! ($certificates.Name -contains $secret.name)) {
        Backup-AzureKeyVaultSecret -Name $secret.name -VaultName $keyvaultName -OutputFile "$backupFolder\secret-$($secret.name)" | Out-Null
    }
}

#keys
$keys = Get-AzureKeyVaultKey -VaultName $keyvaultName
foreach ($kvkey in $keys) {
    #Exclude any keys automatically generated when creating a cert, as these cannot be backed up   
    if (! ($certificates.Name -contains $kvkey.name)) {
        Backup-AzureKeyVaultKey -Name $kvkey.name -VaultName $keyvaultName -OutputFile "$backupFolder\key-$($kvkey.name)" | Out-Null
    }
}
    
# #Managed Storage Accounts - disabled currently due to restore issues
# $saccounts = Get-AzureKeyVaultManagedStorageAccount -VaultName $keyvaultName
# foreach ($saccount in $saccounts) {
#     Backup-AzureKeyVaultManagedStorageAccount -Name $saccount.name -VaultName $keyvaultName -OutputFile "$backupFolder\managedstorageaccount-$($saccount.name)" | Out-Null
        
# }

Write-Output "Local file backup complete"    
####### Copy files to Azure Files
Write-Output "Starting upload of backup to Azure Files"
$storageAccount = Get-AzureRmStorageAccount -ResourceGroupName $storageResourceGroup -Name $storageAccountName 
$files = Get-ChildItem $backupFolder
$backupFolderName = Split-Path $backupFolder -Leaf

#Create backup folder if it does not exist
$backupFolderTest = Get-AzureStorageFile -Context $storageAccount.Context -ShareName $fileshareName -Path $backupFolderName
if (! $backupFolderTest) {
    New-AzureStorageDirectory -Context $storageAccount.Context -ShareName $fileshareName -Path $backupFolderName
}
#upload files, overwriting existing
foreach ($file in $files) {
    Set-AzureStorageFileContent -Context $storageAccount.Context -ShareName $fileshareName -Source $file.FullName -Path "$backupFolderName\$($file.name)" -Force
    
}

Remove-Item $backupFolder -Recurse -Force

Write-Output "Upload complete"
Write-Output "Backup Complete"

