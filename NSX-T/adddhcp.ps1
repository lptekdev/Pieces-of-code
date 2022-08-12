#####TO CREATE A NEW DHCP CONFIG SERVER##### NOT CONCLUDED

param ($segment_name, $tier_1_id)



$SECPASS = ConvertTo-SecureString '' -AsPlainText -Force
$CRED = New-Object System.Management.Automation.PSCredential ('', $SECPASS)




####Criar o DHCP config#####
$Url = "https://nsxtmanager.home.lan/policy/api/v1/infra/dhcp-server-configs/dhcp_"+$segment_name
$Body = [PSCustomObject]@{
  edge_cluster_path = "/infra/sites/default/enforcement-points/default/edge-clusters/70bde1d6-d998-4086-b83b-4d84990f8d36"
  server_address= "172.16.10.2/24"
  lease_time= 86400
  resource_type = "SegmentDhcpV4Config"
} | ConvertTo-Json

$headers = @{
    'Content-Type' = 'application/json'
}


#Invoke-RestMethod -Method 'PUT' -Uri $Url -Credential $CRED -Body $Body -Authentication "Basic" -SkipCertificateCheck -Headers $headers

try {
  #$web_request = Invoke-WebRequest -Method 'PUT' -Uri $Url -Credential $CRED -Body $Body -Authentication "Basic" -SkipCertificateCheck -Headers $headers
  $web_request = Invoke-RestMethod -Method 'PUT' -Uri $Url -Credential $CRED -Body $Body -Authentication "Basic" -SkipCertificateCheck -Headers $headers
  $web_request 
 
    # This will only execute if the Invoke-WebRequest is successful.
    #$StatusCode = $web_request
}
catch
{
  Write-host "Request failed"
    $StatusCode = $_.ErrorDetails.Message
    $StatusCode |ConvertFrom-Json |Select -ExpandProperty error_message
    #$_.Exception
}


