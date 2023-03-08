#Pass Parameters
Param(
[Parameter(Mandatory=$true)]
[String] $Email,
[Parameter(Mandatory=$true)]
[String] $ResourceGroupname,
[Parameter(Mandatory=$true)]
[String] $Role,
[Parameter(Mandatory=$true)]
[String] $SubscriptionId,
[Parameter(Mandatory=$true)]
[String] $Name
)

$subid = $SubscriptionId
$rgname = $ResourceGroupname
$emailadress = $Email
$rolename = $Role

#Install-Module -Name Az -Force

#Install-Module -Name AzureAD -Force

#Install-Module -Name Microsoft.Graph.Identity.SignIns -Force

#Install-Module -Name Microsoft.Graph.Users -Force


#$username = "User01@tejaswinigundapaneni972gmai.onmicrosoft.com"
#$password = ConvertTo-SecureString "Vayo00690" -AsPlainText -Force
#$Creds = New-Object System.Management.Automation.PSCredential ($username, $password)

$username = "27930b05-22ee-4092-92b9-d525dc3378b8" 
$password = "AZF8Q~RfDiysSIOb_gOblsx-FFwDmrM7ttjjsdwQ" 

$SecureStringPwd = $password | ConvertTo-SecureString -AsPlainText -Force

$Creds = New-Object System.Management.Automation.PSCredential ($username, $SecureStringPwd)

Connect-Azaccount -ServicePrincipal -Credential $Creds -TenantId "0704a279-cf35-4ffe-bf19-58bec252f8bb"

$userdetails = Get-AzADUser -ObjectId $Email

$userprincipalname = $Email

function CreateRG($subid, $rgname, $rolename){

Connect-Azaccount -ServicePrincipal -Credential $Creds -TenantId "0704a279-cf35-4ffe-bf19-58bec252f8bb"

Select-AzSubscription -Subscription $subid
try
{
Get-AzResourceGroup -Name $rgname
}
Catch{
New-AzResourceGroup -Name $rgname -Location "East US"
}
}

if($userdetails.Id -ne $null)
{
Write-Host "User exists in the Active Directory"

CreateRG $subid $rgname $rolename 

Connect-Azaccount -ServicePrincipal -Credential $Creds -TenantId "0704a279-cf35-4ffe-bf19-58bec252f8bb"

New-AzRoleAssignment -SignInName $Email -RoleDefinitionName $rolename -ResourceGroupName $rgname 

}
else
{

Write-Host "User does not exists in the Active Directory, user will be added now"

Connect-MgGraph -Scopes 'User.ReadWrite.All' -UseDeviceAuthentication

New-MgInvitation -InvitedUserDisplayName $Name -InvitedUserEmailAddress $emailadress -InviteRedirectUrl "https://myapplications.microsoft.com" -SendInvitationMessage:$true

sleep 30

$newuser = Get-MgUser -Filter "Mail eq '$emailadress'"

CreateRGandAssignPermission $subid $rgname $rolename 

Connect-Azaccount -ServicePrincipal -Credential $Creds -TenantId "0704a279-cf35-4ffe-bf19-58bec252f8bb"

New-AzRoleAssignment -SignInName $newuser.UserPrincipalName -RoleDefinitionName $rolename -ResourceGroupName $rgname 

}





