param(
$dns_name,
$ip_address,
$zone
)

Add-DnsServerResourceRecordA -Name $dns_name -ZoneName $zones -IPv4Address $ip_address –CreatePtr:$true