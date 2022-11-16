# For a specific VM remove all the hard disks with specified capacityc
Get-VM -Name "vm_name" |Get-HardDisk |foreach { if ($_.CapacityGB -eq "disk_size") {write $_.Filename; Remove-HardDisk -DeletePermanently:$true -HardDisk $_}}


# Add virtual disk in the datastore returned by the first virtual disk of the VM
Get-VM -Name "vm_name*" | foreach { New-HardDisk -VM $_ -CapacityGB "disk_size" -ThinProvisioned -Datastore (foreach { $_ |Get-HardDisk  |Get-Datastore |select $first} )}