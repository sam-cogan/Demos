$keyvault="sqlAgentDemoKV"
$resourceGroup="SQLAgentDemos"

$backupFolder = "$env:Temp\KeyvaultBackup"

If((test-path $backupFolder))
{
    Remove-Item $backupFolder -Recurse -Force

}

New-Item -ItemType Directory -Force -Path $backupFolder
New-Item -ItemType Directory -Force -Path "$backupFolder\secrets"
New-Item -ItemType Directory -Force -Path "$backupFolder\certificates"
New-Item -ItemType Directory -Force -Path "$backupFolder\keys"
New-Item -ItemType Directory -Force -Path "$backupFolder\managedstorageaccount"

###Certificates

$certificates=Get-AzureKeyVaultCertificate -VaultName $keyvault 

foreach($cert in $certificates){
    Backup-AzureKeyVaultCertificate -Name $cert.name -VaultName $keyvault -OutputFile "$backupFolder\certificates\$($cert.name)"
}

###Secrets
$secrets=Get-AzureKeyVaultSecret -VaultName $keyvault 

foreach($secret in $secrets){
#Exclude any secerets automatically generated when creatoing a cert, as these cannot be backed up   
    if(! ($certificates.Name -contains $secret.name)){
    write-host "backing up secret $($secret.name)"
    Backup-AzureKeyVaultSecret -Name $secret.name -VaultName $keyvault -OutputFile "$backupFolder\secrets\$($secret.name)"
    }
}

#keys
$keys=Get-AzureKeyVaultKey -VaultName $keyvault 
foreach($kvkey in $keys){
    #Exclude any keys automatically generated when creatoing a cert, as these cannot be backed up   
        if(! ($certificates.Name -contains $kvkey.name)){
        write-host "backing up key $($kvkey.name)"
        Backup-AzureKeyVaultKey -Name $kvkey.name -VaultName $keyvault -OutputFile "$backupFolder\keys\$($kvkey.name)"
        }
    }
    
#Managed Stoorage Accounts
$saccounts=Get-AzureKeyVaultManagedStorageAccount -VaultName $keyvault 
foreach($saccount in $saccounts){

        Backup-AzureKeyVaultManagedStorageAccount -Name $saccount.name -VaultName $keyvault -OutputFile "$backupFolder\managedstorageaccount\$($saccount.name)"
        
    }
    

