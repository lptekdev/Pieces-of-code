param(
    $edge_cluster_name,
    $segment_name, $dhcp_server_address
)
Import-Module ".\nsxmodule.psm1"

write-host "1- Loading environment file info" -ForegroundColor DarkGreen
$credentials = LoadAccessData


$SECPASS = ConvertTo-SecureString ($credentials.password) -AsPlainText -Force
$CRED = New-Object System.Management.Automation.PSCredential ($credentials.username, $SECPASS)

write-host ""
write-host "2- Reading Edge Cluster info" -ForegroundColor  DarkGreen
$edge_cluster = getEdgeCluster -edge_cluster_name $edge_cluster_name -credentials $CRED

if ($edge_cluster.status -ne 200){
    #write-host $edge_cluster.message
    #$color
    if ($edge_cluster.status -eq 404){
        write-host $edge_cluster.message -ForegroundColor  DarkYellow   
    }
    else {
        write-host $edge_cluster.message -ForegroundColor  DarkRed  
    }    
    break
}
else {
    write-host "Found Edge Cluster: "$edge_cluster.message -ForegroundColor DarkGreen
    write-host
    write-host "2- Creating DHCP Config" -ForegroundColor  DarkGreen
    $dhcp = NewDHCP -segment_name $segment_name -edge_cluster $edge_cluster.message  -server_address $dhcp_server_address -credentials $CRED
    
    if ($dhcp.status -notlike "CREATED"){
        write-host "Error creating DHCP: "$dhcp.message" - "$dhcp.status -ForegroundColor DarkRed
        break
    }
    else {
        write-host "Created DHCP Config sucessfully: "$dhcp.path" - "$dhcp.server_address -ForegroundColor DarkGreen

        write-host "2- Creating new Segment" -ForegroundColor  DarkGreen
        $segment
    }

    
}







Remove-Module nsxmodule