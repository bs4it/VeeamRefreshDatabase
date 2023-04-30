# Fernando Della Torre @2023

##### VARIABLES #####

$OriginalVM = "BDPROD"
$OriginalDBName = "agrdb"
$DestinationVM = "srvoradev01.work.local"
$DestinationDBName = "TAGRDB"
$DestinationUser = "oracle"
$DestinationRootUser = "root"

##### VARIABLES #####

### CODE ###
$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
write-host $scriptPath
$DestinationPassword = Get-Content $scriptPath\$DestinationUser".pass" | ConvertTo-SecureString
write-host $DestinationPassword
$DestinationRootPassword = Get-Content $scriptPath\$DestinationRootUser".pass" | ConvertTo-SecureString
$Credentials = New-VEORLinuxCredential -Account "oracle" -Password (ConvertTo-SecureString $DestinationPassword -AsPlainText -Force) -ElevateAccountToRoot -RootPassword (ConvertTo-SecureString $DestinationRootPassword -AsPlainText -Force) -UseSuIfSudoUnavailable
$Date = Get-Date -Format "yyyy/MM/dd HH:mm"
Write-Host "Starting restore at $Date" 
$LatestBackup = Get-VBRApplicationRestorePoint -Oracle -Name  $OriginalVM|  Sort -Property CreationTime -Descending | Select -First 1
$RestoreSession = Start-VEORRestoreSession -RestorePoint $LatestBackup
$OriginalDatabase = Get-VEORDatabase -Session $RestoreSession -Name $OriginalDBName
$DatabaseFiles = Get-VEORDatabaseFile -Database $OriginalDatabase
Restore-VEORDatabase -Force -Database $OriginalDatabase -Server $DestinationVM -GlobalDatabaseName $DestinationDBName -LinuxCredentials $Credentials -File $DatabaseFiles -TargetPath ($DatabaseFiles.Path -replace $OriginalDBName,$DestinationDBName)
Stop-VEORRestoreSession $RestoreSession
$Date = Get-Date -Format "yyyy/MM/dd HH:mm"
Write-Host "Finished restore at $Date"
