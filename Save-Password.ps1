$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
$cred=Get-Credential
$pass=$cred.Password
$username=$cred.UserName
$pass | ConvertFrom-SecureString | set-content $scriptPath\$username".pass"
Write-host $scriptPath\$username".pass"