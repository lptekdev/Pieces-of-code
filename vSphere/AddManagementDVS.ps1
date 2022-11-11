param(
$dvsname,
$cluster,
$nic1,
$nic2
)

#add to service dvswitch
$servers = get-cluster -name $cluster |get-vmhost

#$dvsname = "dvSwitch-Internal"
$dvs = Get-VDSwitch -Name $dvsname
$nics = @()
$nics += $nic1
$nics += $nic2

foreach ($server in $servers){
	$dvs | Add-VDSwitchVMHost -VMHost $server
	#Get-VMHostNetworkAdapter -VMHost $server -Portgroup "Management"
	$vmk0 = Get-VMHostNetworkAdapter -VMHost $server -Portgroup "Management Network"
	$management_vd_pg = Get-VDPortGroup -Name "Management-40" -VDSwitch $vds
	Add-VDSwitchPhysicalNetworkAdapter -DistributedSwitch $dvs -VMHostPhysicalNic $nics -VMHostVirtualNic $vmk0 -VirtualNicPortgroup $management_vd_pg
}

Get-VDPortgroup -Name "Management-40" |Get-VDUplinkTeamingPolicy |Set-VDUplinkTeamingPolicy -ActiveUplinkPort "Uplink 1" -StandbyUplinkPort "Uplink 2"






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