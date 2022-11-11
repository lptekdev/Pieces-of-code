#$hosts_esxi = @()
#$hosts_esxi = get-content "hosts.txt"
#$location = ""

param(
	$esxi,
	$cluster
)

$credentials = Get-Credential -UserName root -Message "Enter the ESXi root password"

#Add ESXi to cluster
Add-VMHost -name $esxi -Location $cluster -User $credentials.UserName -Password $credentials.GetNetworkCredential().Password -force:$true
Get-VMHost -Name $esxi | set-vmhost -State Maintenance