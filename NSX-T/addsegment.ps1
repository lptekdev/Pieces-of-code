###TO ADD A NEW NSX-T SEGMENT######  NOT CONCLUDED

param ($segment_name)



$nsx = Import-Module ".\nsxmodule.psm1"
$credentials =LoadAccessData


$SECPASS = ConvertTo-SecureString $credentials.password -AsPlainText -Force
$CRED = New-Object System.Management.Automation.PSCredential ($credentials.username, $SECPASS)




#####criar segment #####
$Url = "https://nsxtmanager.home.lan/policy/api/v1/infra/segments/"+$segment_name+"?force=true"

$body = @{}
$body.Add("advanced_config",@{})
$body.Add("connectivity_path","/infra/tier-1s/Default_T1")
$body.Add("transport_zone_path","/infra/sites/default/enforcement-points/default/transport-zones/505154a4-27d3-428d-9648-f4f410f951f5")
$body.Add("type","ROUTED")
#$subnets =



$subnets = new-object PSObject
$subnets | add-member -type NoteProperty -Name gateway_address -Value "172.16.10.1/24"
$subnets | add-member -type NoteProperty -Name network -Value "172.16.10.0/24"
$subnets | add-member -type NoteProperty -Name dhcp_ranges -Value @("172.16.10.100-172.16.10.200")
$subnets | Add-Member -type NoteProperty -Name dhcp_config -Value @{server_address="172.16.10.2/24";resource_type="SegmentDhcpV4Config"}

$array = @()
$array += $subnets
$body.Add("subnets",$array)

$body.Add("dhcp_config_path", "/infra/dhcp-server-configs/dhcp_veeam")


$body = $body |ConvertTo-Json -Depth 3
write-host $body


$headers = @{
    'Content-Type' = 'application/json'
}



#write-host $Body 
Invoke-RestMethod -Method 'PUT' -Uri $url -Credential $CRED -Body $Body -Authentication "Basic" -SkipCertificateCheck -Headers $headers