####NSX-T MODULE TO USE ALLL FUNCTIONS####


function NewDHCP {
    param ($segment_name, $server_address_cidr)


    $SECPASS = ConvertTo-SecureString '' -AsPlainText -Force
    $CRED = New-Object System.Management.Automation.PSCredential ('', $SECPASS)
    
    
    
    ####Criar o DHCP config#####
    $Url = "https://nsxtmanager.home.lan/policy/api/v1/infra/dhcp-server-configs/dhcp_"+$segment_name
    $Body = [PSCustomObject]@{
      edge_cluster_path = "/infra/sites/default/enforcement-points/default/edge-clusters/"
      server_address= "$server_address_cidr"
      lease_time= 86400
      resource_type = "SegmentDhcpV4Config"
    } | ConvertTo-Json
    
    $headers = @{
        'Content-Type' = 'application/json'
    }
    
    try {
        $web_request = Invoke-WebRequest -Method 'PUT' -Uri $Url -Credential $CRED -Body $Body -Authentication "Basic" -SkipCertificateCheck -Headers $headers
       
    }
    catch {
        write-host "Error when creating DHCP SERVER config"    
       
}


    return  $web_request  #    : /infra/dhcp-server-configs/dhcp_veeam
}





function NewNSXSegment {
    param ($segment_name, $dhcp_config_path, $gateway_adress, $network, $dhcp_ranges )

    

    #####criar segment #####
    $Url = "https://nsxtmanager.home.lan/policy/api/v1/infra/segments/"+$segment_name+"?force=true"

    $body = @{}
    $body.Add("advanced_config",@{})
    $body.Add("connectivity_path","/infra/tier-1s/Default_T1")
    $body.Add("transport_zone_path","/infra/sites/default/enforcement-points/default/transport-zones/")
    $body.Add("type","ROUTED")
    #$subnets =



    $subnets = new-object PSObject
    $subnets | add-member -type NoteProperty -Name gateway_address -Value $gateway_adress
    $subnets | add-member -type NoteProperty -Name network -Value $network
    $subnets | add-member -type NoteProperty -Name dhcp_ranges -Value @("$dhcp_ranges")
    $subnets | Add-Member -type NoteProperty -Name dhcp_config -Value @{server_address="$server_address";resource_type="SegmentDhcpV4Config"}

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
        
}



    

Export-ModuleMember -Function NewNSXSegment
Export-ModuleMember -Function NewDHCP