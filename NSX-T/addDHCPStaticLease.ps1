###TO ADD A NEW NSX-T SEGMENT######  NOT CONCLUDED

param ($segment_name, $ip_address, $vm_name, $gateway, $mac, $dns)



$nsx = Import-Module ".\nsxmodule.psm1"
$credentials =LoadAccessData


$SECPASS = ConvertTo-SecureString $credentials.password -AsPlainText -Force
$CRED = New-Object System.Management.Automation.PSCredential ($credentials.username, $SECPASS)





$Url = "https://nsxtmanager.home.lan/policy/api/v1/infra/segments/"+$segment_name+"/dhcp-static-binding-configs/lease_"+$vm_name


#Json body for creating the DHCP static lease#
$body = @{}
$body.Add("display_name","lease_"+$vm_name)
$body.Add("resource_type","DhcpV4StaticBindingConfig")
$body.Add("gateway_address",$gateway)
$body.Add("mac_address",$mac)
$body.Add("ip_address",$ip_address)

if ($dns) {
    $others = new-object PSObject
    $others | add-member -type NoteProperty -Name code -Value 6
    $others | add-member -type NoteProperty -Name values -Value @($dns)
    
    $new_others_array = @()
    $new_others_array += $others
    $others_object = @{}
    $others_object.Add("others",$new_others_array)
    $body.Add("options",$others_object)
}




$body = $body |ConvertTo-Json -Depth 4

$headers = @{
    'Content-Type' = 'application/json'
}

#invoke NSX-T API to create the static lease#
Invoke-RestMethod -Method 'PUT' -Uri $Url -Credential $CRED -Body $body -Authentication "Basic" -SkipCertificateCheck -Headers $headers