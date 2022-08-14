#bal:username
#$global:password
#$global:transport_zone



function LoadAccessData(){
  $data = Get-Content info.json | ConvertFrom-Json
  return $data
}



function getEdgeCluster(){

######GET THE EDGE CLUSTER ID BASED ON NAME TO USE IT IN THE DHCP CREATION#####
  param ($edge_cluster_name, $credentials)

  $Url = "https://nsxtmanager.home.lan/api/v1/edge-clusters"

  $headers = @{
      'Content-Type' = 'application/json'
  }


  try {
    write-host "Invoking API GET edge cluster ID" -ForegroundColor DarkYellow
    $edge_clusters_array = Invoke-RestMethod -Method 'GET' -Uri $Url -Credential $credentials -Authentication "Basic" -SkipCertificateCheck -Headers $headers
    
    foreach($edge_cluster in $edge_clusters_array.results){
      #$edge_cluster.display_name
      #$edge_cluster_json = $edge_cluster 
      if ($edge_cluster.display_name -like $edge_cluster_name) {
          #$edge_cluster.id
          $response = @{
            status = 200
            message = $edge_cluster.id
          }
          return $response
      }
    }
    write-host "Edge Cluster not found" -ForegroundColor DarkYellow
    $response = @{
      status = 404
      message = "NotFound"
    }
    return $response
  
      # This will only execute if the Invoke-WebRequest is successful.
      #$StatusCode = $web_request
  }
  catch
  {
    write-host "FAILED Invoking API for GET" -ForegroundColor DarkRed    
      $err = $_.ErrorDetails.Message |ConvertFrom-Json
      #$StatusCode
       $response = @{
            status = $err.error_code
            message = $err.error_message
          }
          return $response     
  }
}

function NewDHCP() {
  #####TO CREATE A NEW DHCP CONFIG SERVER##### NOT CONCLUDED

  param ($segment_name, $edge_cluster, $server_address, $credentials)

  ####Create o DHCP config#####
  
  $Url = "https://nsxtmanager.home.lan/policy/api/v1/infra/dhcp-server-configs/dhcp_"+$segment_name
  $Body = [PSCustomObject]@{
    edge_cluster_path = "/infra/sites/default/enforcement-points/default/edge-clusters/"+$edge_cluster
    server_address= $server_address
    lease_time= 86400
    resource_type = "SegmentDhcpV4Config"
  } | ConvertTo-Json

  $headers = @{
      'Content-Type' = 'application/json'
  }

  try {
    write-host "Invoking API PUT to create DHCP config" -ForegroundColor DarkYellow
    $web_request = Invoke-RestMethod -Method 'PUT' -Uri $Url -Credential $credentials -Body $Body -Authentication "Basic" -SkipCertificateCheck -Headers $headers
    return $web_request 
  
  }
  catch
  {
    Write-host "Request failed" -ForegroundColor DarkRed
      $StatusCode = $_.ErrorDetails.Message
      $StatusCode |ConvertFrom-Json |Select -ExpandProperty error_message
      #$_.Exception
  }

}



Export-ModuleMember -Function getEdgeCluster
Export-ModuleMember -Function NewDHCP
Export-ModuleMember -Function LoadAccessData




