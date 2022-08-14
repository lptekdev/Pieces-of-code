#####TO CREATE A NEW DHCP CONFIG SERVER##### NOT CONCLUDED

param ($segment_name, $edge_cluster, $server_address)

$nsx = Import-Module ".\nsxmodule.psm1"
$credentials =LoadAccessData


$SECPASS = ConvertTo-SecureString $credentials.password -AsPlainText -Force
$CRED = New-Object System.Management.Automation.PSCredential ($credentials.username, $SECPASS)

$headers = @{
    'Content-Type' = 'application/json'
}


  $Url = "https://nsxtmanager.home.lan/policy/api/v1/infra/dhcp-server-configs/dhcp_"+$segment_name
  
  $headers = @{
    'Content-Type' = 'application/json'
  }

  $Body = [PSCustomObject]@{
    edge_cluster_path = "/infra/sites/default/enforcement-points/default/edge-clusters/"+$edge_cluster
    server_addresses= @($server_address)
    lease_time= 86400
    resource_type = "DhcpServerConfig"
    display_name = "dhcp_"+$segment_name
    id = "dhcp_"+$segment_name
  } | ConvertTo-Json

  write-host "Invoking API PUT to create DHCP config" -ForegroundColor DarkYellow
  #$Body
  try {
    $dhcp = Invoke-RestMethod -Method 'PUT' -Uri $Url -Credential $CRED -Body $Body -Authentication "Basic" -SkipCertificateCheck -Headers $headers 
    $dhcp
    
    #$dhcp = Invoke-WebRequest -Method 'PUT' -Uri $Url -Credential $CRED -Body $Body -Authentication "Basic" -SkipCertificateCheck -Headers $headers    
    
    $response = @{
      status = "CREATED"
      message = $dhcp.path
      server_address = $dhcp.server_address
    }
    return $response

  }
catch
{
  Write-host "Request failed" -ForegroundColor Red
  #$err = $_.ErrorDetails.Message |ConvertFrom-Json  
  write-host $_.ErrorDetails
  write-host $_.Exception
  $err = $_.ErrorDetails#.Message |ConvertFrom-Json  
  $err  
  $response = @{
        status = $err.httpStatus
        message = $err.error_message
  }
  return $response 
}




