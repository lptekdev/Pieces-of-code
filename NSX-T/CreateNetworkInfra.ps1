param(
    $edge_cluster_name,
    $segment_name, $edge_cluster, $dhcp_server_address
)
Import-Module ".\nsxmodule.psm1"

write-host "Loading environment file info" -ForegroundColor DarkGreen
$credentials = LoadAccessData


$SECPASS = ConvertTo-SecureString ($credentials.password) -AsPlainText -Force
$CRED = New-Object System.Management.Automation.PSCredential ($credentials.username, $SECPASS)


write-host "Reading Edge Cluster info" -ForegroundColor  DarkGreen
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
    write-host "Creating DHCP Config" -ForegroundColor  DarkGreen
    $dhcp_config = NewDHCP -segment_name $segment_name -edge_cluster $edge_cluster.id  -server_address $dhcp_server_address -credentials $credentials
}







Remove-Module nsxmodule