param(
$dvsname,
$vssname,
$nic1,
$nic2,
$management_pg,
$esxi,
$vlan,
$vmkernel
)


# get the required information
$physicalNic1 = Get-VMHostNetworkAdapter -VMHost $esxi -Name $nic1
$physicalNic2 = Get-VMHostNetworkAdapter -VMHost $esxi -Name $nic2
$dvs = Get-VDSwitch -Name $dvsname
$vss = Get-VirtualSwitch -VMHost $esxi -name "vSwitch0"

$pnics = @()
$pnics += $physicalNic1
$pnics += $physicalNic2


try {
    # Get the management vmkernel
    $vmkernels = Get-VMHostNetworkAdapter -VirtualSwitch $dvs -VMHost $esxi -Portgroup $management_pg -VMKernel
    $vmk0 = $vmkernels |where Name -eq $vmkernel
    
    # Create the Standart port group for management
    $vportgroup = New-VirtualPortGroup -VirtualSwitch $vss -Name $management_pg -VLanId $vlan

    # Add pNIC to VSS and migrate the vmkernel to new port group on VSS
    Add-VirtualSwitchPhysicalNetworkAdapter -VMHostPhysicalNic $pnics[0] -VirtualSwitch $vss -VirtualNicPortgroup $vportgroup -VMHostVirtualNic $vmk0 

    # Add the second pNIC to VSS
    Add-VirtualSwitchPhysicalNetworkAdapter -VMHostPhysicalNic $pnics[1] -VirtualSwitch $vss

    # Remove host from VDS
    Remove-VDSwitchVMHost -VDSwitch $dvs -VMHost $esxi
}
catch {
    write-host $_
	#Write-host "unable to get physical nics or add host to dvs or migrate the vmkernel"
}


