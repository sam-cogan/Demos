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

    
    [Parameter(Mandatory = $True)]
    [string]$backupFolder,
   
    [string]$tempRestoreFolder = "$env:Temp\KeyVaultRestore"
 
)

#Create temporary folder to download files
If ((test-path $tempRestoreFolder)) {
    Remove-Item $tempRestoreFolder -Recurse -Force

}
New-Item -ItemType Directory -Force -Path $tempRestoreFolder | Out-Null

Write-Output "Starting download of backup to Azure Files"
$storageAccount = Get-AzureRmStorageAccount -ResourceGroupName $storageResourceGroup -Name $storageAccountName 


#Download files from Azure File Share
$backupFolderTest = Get-AzureStorageFile -Context $storageAccount.Context -ShareName $fileshareName -Path $backupFolderName
if (! $backupFolderTest) {
    Write-Error "Backup folder in Azure File Share Not Found"
    exit
}

$backupFiles = Get-AzureStorageFile -ShareName $fileshareName -Path $backupFolder  -Context $storageAccount.Context | Get-AzureStoragefile

foreach ($backupFile in $backupFiles ) {
    Write-Output "downloading $backupFolder\$($backupFile.name)"
    Get-AzureStorageFileContent -ShareName $fileshareName -Path "$backupFolder\$($backupFile.name)" -Destination "$tempRestoreFolder\$($backupFile.name)"  -Context $storageAccount.Context 
}

#Restore secrets to KV

Write-Output "Starting Restore"

$secrets = get-childitem $tempRestoreFolder | where-object {$_ -match "^(secret-)"}
$certificates = get-childitem $tempRestoreFolder | where-object {$_ -match "^(certificate-)"}
$keys = get-childitem $tempRestoreFolder | where-object {$_ -match "^(key-)"}

foreach ($secret in $secrets) {
    write-output "restoring $($secret.FullName)"
    Restore-AzureKeyVaultSecret -VaultName $keyvaultName -InputFile $secret.FullName 
}

foreach ($certificate in $certificates) {
    write-output "restoring $($certificate.FullName) "
    Restore-AzureKeyVaultCertificate -VaultName $keyvaultName -InputFile $certificate.FullName 
}

foreach ($key in $keys) {
    write-output "restoring $($key.FullName)  "
    Restore-AzureKeyVaultKey -VaultName $keyvaultName -InputFile $key.FullName 
}

Remove-Item $tempRestoreFolder -Recurse -Force


Write-Output "Restore Complete"

