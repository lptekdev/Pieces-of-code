param (
    $esxi,
    [bool]$vmotion=$false,
    [bool]$vsan=$false,
    $ip_adddress,
    $SubnetMask,
    $portgroup,
    $vswitch
)

#get host and DVS
$dvs = Get-VDSwitch -Name $vswitch
try {
    New-VMHostNetworkAdapter -VMHost $esxi -PortGroup $portgroup -IP $ip_adddress -SubnetMask $SubnetMask -VirtualSwitch $dvs -VMotionEnabled $vmotion -VsanTrafficEnabled $vsan
}
catch {
    $_
}
