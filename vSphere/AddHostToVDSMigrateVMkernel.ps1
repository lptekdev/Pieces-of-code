param(
$dvsname,
$nic1,
$nic2,
$source_vmkernel_pg,
$destination_vnkernel_pg,
$esxi
)


# get the distributeed switch and creates the vmnics array
$dvs = Get-VDSwitch -Name $dvsname
$pnics = @()


# add esxi to DVS and migrates the management vmkernel on standard switch to DVS switch for the specified distributed port group for management

try{
	#get the physical nic based on name of input nics
	$physicalNic1 = Get-VMHostNetworkAdapter -VMHost $esxi -Name $nic1
	$physicalNic2 = Get-VMHostNetworkAdapter -VMHost $esxi -Name $nic2
	$pnics += $physicalNic1
	$pnics += $physicalNic2

	#add host to DVS
	$dvs | Add-VDSwitchVMHost -VMHost $esxi 
	
	#migrate the vmkernel to DVS
	$vmk0 = Get-VMHostNetworkAdapter -VMHost $esxi -Portgroup $source_vmkernel_pg
	$management_vd_pg = Get-VDPortGroup -Name $destination_vnkernel_pg -VDSwitch $dvs			
	Add-VDSwitchPhysicalNetworkAdapter -DistributedSwitch $dvs -VMHostPhysicalNic $pnics -VMHostVirtualNic $vmk0 -VirtualNicPortgroup $management_vd_pg
}	
catch {
	write-host $_
	Write-host "unable to get physical nics or add host to dvs or migrate the vmkernel"
}

### PHYSICAL NICS FOR STANDARD SWITCH #####

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