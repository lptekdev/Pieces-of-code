#####TO CREATE A NEW DHCP CONFIG SERVER##### NOT CONCLUDED

param ($segment_name, $edge_cluster, $server_address)

$nsx = Import-Module ".\nsxmodule.psm1"
$credentials =LoadAccessData


$SECPASS = ConvertTo-SecureString $credentials.password -AsPlainText -Force
$CRED = New-Object System.Management.Automation.PSCredential ($credentials.username, $SECPASS)




####Criar o DHCP config#####
$Url = "https://nsxtmanager.home.lan/policy/api/v1/infra/dhcp-server-configs/dhcp_"+$segment_name
$Body = [PSCustomObject]@{
  edge_cluster_path = "/infra/sites/default/enforcement-points/default/edge-clusters/"+$edge_cluster
  server_address= "172.16.100.2/24"
  lease_time= 86400
  resource_type = "SegmentDhcpV4Config"
} | ConvertTo-Json

$headers = @{
    'Content-Type' = 'application/json'
}

try {
  
  $web_request = Invoke-RestMethod -Method 'PUT' -Uri $Url -Credential $CRED -Body $Body -Authentication "Basic" -SkipCertificateCheck -Headers $headers
  return $web_request 
}
catch
{
  Write-host "Request failed"
    $StatusCode = $_.ErrorDetails.Message
    $StatusCode |ConvertFrom-Json |Select -ExpandProperty error_message
    #$_.Exception
}


