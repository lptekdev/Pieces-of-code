######GET THE EDGE CLUSTER ID BASED ON NAME TO USE IT IN THE DHCP CREATION#####


param ($edge_cluster_name)



$SECPASS = ConvertTo-SecureString '' -AsPlainText -Force
$CRED = New-Object System.Management.Automation.PSCredential ('', $SECPASS)




####Criar o DHCP config#####
$Url = "https://nsxtmanager.home.lan/api/v1/edge-clusters"

$headers = @{
    'Content-Type' = 'application/json'
}


#Invoke-RestMethod -Method 'PUT' -Uri $Url -Credential $CRED -Body $Body -Authentication "Basic" -SkipCertificateCheck -Headers $headers

try {
  #$web_request = Invoke-WebRequest -Method 'PUT' -Uri $Url -Credential $CRED -Body $Body -Authentication "Basic" -SkipCertificateCheck -Headers $headers
  $edge_clusters_array = Invoke-RestMethod -Method 'GET' -Uri $Url -Credential $CRED -Authentication "Basic" -SkipCertificateCheck -Headers $headers
  #$web_request
  foreach($edge_cluster in $edge_clusters_array.results){
    #$edge_cluster.display_name
    #$edge_cluster_json = $edge_cluster 
    if ($edge_cluster.display_name -like $edge_cluster_name) {
        $edge_cluster.id
        return $edge_clusters.id
    }
  }
  write-host "Edge Cluster not found"
 
    # This will only execute if the Invoke-WebRequest is successful.
    #$StatusCode = $web_request
}
catch
{
    Write-host "Request failed"
    $StatusCode = $_.ErrorDetails
    $StatusCode
    #$StatusCode |ConvertFrom-Json |Select -ExpandProperty error_message
    #$_.Exception
}



