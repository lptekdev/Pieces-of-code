param(
$dvsname,
$cluster,
$nic1,
$nic2,
$management_pg,
[bool]$teaming_policy =$true
)

#get all the hosts in the cluster
$servers = get-cluster -name $cluster |get-vmhost

# get the distributeed switch and creates the vmnics array
$dvs = Get-VDSwitch -Name $dvsname
$pnics = @()
$success_added_host = $false


# for each esxi, add to DVS and migrates the management vmkernel on standard switch to DVS switch for the specified distributed port group for management
foreach ($server in $servers){
	
	try{
		#get the physical nic based on name of input nics
		$physicalNic1 = Get-VMHostNetworkAdapter -VMHost $server -Name $nic1
		$physicalNic2 = Get-VMHostNetworkAdapter -VMHost $server -Name $nic2
		$pnics += $physicalNic1
		$pnics += $physicalNic2

		#add host to DVS
		$dvs | Add-VDSwitchVMHost -VMHost $server
		
		#migrate the vmkernel to DVS
		$vmk0 = Get-VMHostNetworkAdapter -VMHost $server -Portgroup "Management Network"
		$management_vd_pg = Get-VDPortGroup -Name $management_pg -VDSwitch $dvs			
		Add-VDSwitchPhysicalNetworkAdapter -DistributedSwitch $dvs -VMHostPhysicalNic $pnics -VMHostVirtualNic $vmk0 -VirtualNicPortgroup $management_vd_pg
		$success_added_host = $true
	}	
	catch {
		write-host $_
		Write-host "unable to get physical nics or add host to dvs or migrate the vmkernel"
	}

}

# if teaming policy is set to true, then changes the active/standby uplink configuration on the distributed port group used for management
if ($teaming_policy -and $success_added_host){
	Get-VDPortgroup -Name $management_pg |Get-VDUplinkTeamingPolicy |Set-VDUplinkTeamingPolicy -ActiveUplinkPort "Uplink 1" -StandbyUplinkPort "Uplink 2"	
}







###### PHYSICAL NICS FOR STANDARD SWITCH #####

<#
$VMNICS = @()
$VMNICS += "vmnic0"
$VMNICS += "vmnic4"
foreach ($VMNIC in $VMNICS)
{
	$vmhostNetworkAdapter = Get-VMHost $VMHost | Get-VMHostNetworkAdapter -Physical -Name $VMNIC
	Get-VDSwitch $dvs | Add-VDSwitchPhysicalNetworkAdapter -VMHostNetworkAdapter $vmhostNetworkAdapter -Confirm:$false
}

#add to dvswitch internal
$dvsname = "Internal"
$dvs = Get-VDSwitch -Name $dvsname
$dvs | Add-VDSwitchVMHost -VMHost $VMHost
#>
###### END PHYSICAL NICS FOR STANDARD SWITCH #####