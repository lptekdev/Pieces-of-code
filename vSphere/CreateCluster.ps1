# creates a new cluster in the specified datacenter #

param(
	$datacenter,
	$name
)

New-Cluster -Name $name -Location $datacenter