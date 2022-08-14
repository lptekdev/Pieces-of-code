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
    $dhcp = Invoke-RestMethod -Method 'PUT' -Uri $Url -Credential $credentials -Body $Body -Authentication "Basic" -SkipCertificateCheck -Headers $headers    
    $response = @{
      status = $dhcp.status == "CREATED"
      message = $dhcp.path
      server_address = $dhcp.server_address
    }
    return $response
  
  }
  catch
  {
    #Write-host "Request failed" -ForegroundColor DarkRed
    $err = $_.ErrorDetails.Message |ConvertFrom-Json  
    $err  
     $response = @{
          status = $err.httpStatus
          message = $err.error_message
        }
        return $response 
  }

}


function NewSegment {
  
  param(
    $transport_zone, $segment_name, $tier1_gw, $network, $gateway, $dhcp_ranges, $dhcp_path, $dhcp_server_ip
  )
  #####criar segment #####
    $Url = "https://nsxtmanager.home.lan/policy/api/v1/infra/segments/"+$segment_name#+"?force=true"

    $body = @{}
    $body.Add("advanced_config",@{})
    $body.Add("connectivity_path","/infra/tier-1s/"+$tier1_gw) #Default_T1" - Tier1 gw name
    $body.Add("transport_zone_path","/infra/sites/default/enforcement-points/default/transport-zones/"+$transport_zone)
    $body.Add("type","ROUTED")
    #$subnets =



    $subnets = new-object PSObject
    $subnets | add-member -type NoteProperty -Name gateway_address -Value $gateway  #"172.16.10.1/24"
    $subnets | add-member -type NoteProperty -Name network -Value $network  #"172.16.10.0/24"
    $subnets | add-member -type NoteProperty -Name dhcp_ranges -Value @($dhcp_ranges)   #@("172.16.10.100-172.16.10.200")
    $subnets | Add-Member -type NoteProperty -Name dhcp_config -Value @{server_address=$dhcp_server_ip;resource_type="SegmentDhcpV4Config"}  #@{server_address="172.16.10.2/24";resource_type="SegmentDhcpV4Config"}

    $array = @()
    $array += $subnets
    $body.Add("subnets",$array)

    $body.Add("dhcp_config_path", $dhcp_path) #"/infra/dhcp-server-configs/dhcp_veeam")


    $body = $body |ConvertTo-Json -Depth 3
    write-host $body


    $headers = @{
        'Content-Type' = 'application/json'
    }



    #write-host $Body 
    write-host "Invoking API PUT to create new SEGMENT" -ForegroundColor DarkYellow
    try {
      $segment = Invoke-RestMethod -Method 'PUT' -Uri $url -Credential $CRED -Body $Body -Authentication "Basic" -SkipCertificateCheck -Headers $headers
    }
    catch
    {    
      $err = $_.ErrorDetails.Message |ConvertFrom-Json  
      $err  
      $response = @{
            status = $err.httpStatus
            message = $err.error_message
          }
          return $response 
    }

  
  
}



Export-ModuleMember -Function getEdgeCluster
Export-ModuleMember -Function NewDHCP
Export-ModuleMember -Function LoadAccessData
Export-ModuleMember -Function NewSegment




