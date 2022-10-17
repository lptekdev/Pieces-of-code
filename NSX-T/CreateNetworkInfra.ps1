param(
    $edge_cluster_name,
    [Parameter(Mandatory=$true)]$segment_name, $dhcp_server_address, 
    $tier1_gw_name, $network, $gateway, $dhcp_ranges
)
Import-Module ".\nsxmodule.psm1" -Force

write-host "1- Loading environment file info" -ForegroundColor DarkGreen
$credentials = LoadAccessData


$SECPASS = ConvertTo-SecureString ($credentials.password) -AsPlainText -Force
$CRED = New-Object System.Management.Automation.PSCredential ($credentials.username, $SECPASS)


#$null -ne $dhcp_server_address
#$null -ne $tier1_gw_name
#$null -ne $gateway
#$null -ne $dhcp_ranges

#$null -ne $edge_cluster_name


if($null -ne $edge_cluster_name){
    ### if to create a segment connected to a T1#
    write-host "2- Reading Edge Cluster info" -ForegroundColor  DarkGreen
    $edge_cluster = getEdgeCluster -edge_cluster_name $edge_cluster_name -credentials $CRED

    if ($edge_cluster.status -ne 200){
        #write-host $edge_cluster.message
        #$color
        if ($edge_cluster.status -eq 404){
            write-host $edge_cluster.message -ForegroundColor  DarkYellow   
        }
        else {
            write-host $edge_cluster.message -ForegroundColor  Red  
        }    
        break
    }
    else {
        write-host "Found Edge Cluster: "$edge_cluster.message -ForegroundColor DarkGreen
        write-host
        $edge_cluster_id=[string]$edge_cluster.message
        write-host "2- Creating DHCP Config" -ForegroundColor  DarkGreen
        $dhcp = NewDHCP -segment_name $segment_name -edge_cluster $edge_cluster_id  -server_address $dhcp_server_address -credentials $CRED    
        if ($dhcp.status -notlike "CREATED"){
            write-host "Error creating DHCP: "$dhcp.message" - "$dhcp.status -ForegroundColor Red
            #write-host "Deleting previous DHCP" -ForegroundColor Yellow
            #Invoke-RestMethod -Uri "https://nsxtmanager.home.lan/policy/api/v1/infra/dhcp-server-configs/dhcp_veeam" -Method "DELETE" -Credential $CRED -Authentication "BASIC" -SkipCertificateCheck 
            #break
        }    
        else {        
            write-host "Created DHCP Config sucessfully: "$dhcp.dhcp_path" - "$dhcp.server_address -ForegroundColor DarkGreen

            write-host "3- Creating new Segment" -ForegroundColor  DarkGreen
            $segment = NewSegment -transport_zone $credentials.transport_zone -segment_name $segment_name -tier1_gw_name $tier1_gw_name -network $network -gateway $gateway -dhcp_ranges $dhcp_ranges -dhcp_path $dhcp.dhcp_path -dhcp_server_ip $dhcp.server_address -credentials $CRED
            $segment
        }
    }  
}
else {
    ### cretes a isolated segment without connecting to T1
    write-host "2- Creating new isolated Segment" -ForegroundColor  DarkGreen
    $segment = NewSegment -transport_zone $credentials.transport_zone -segment_name $segment_name -network $network -credentials $CRED
    $segment
}


Remove-Module nsxmodule