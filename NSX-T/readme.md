Powershell code for consuming NSX-T API <br />
Module for creating DHCP configuratiom, segment; retrieve EdegeCluster and Tier1 gateway info <br />
<br />
**#######IMPORTANT#####**<br />
Modules/scrips were not fully tested yet, but regarding API calls, if the request body is correctly configured, those work as expected.


**EXAMPLE OF USAGE FOR CreateNetworkInfra SCRIPT** 
.\CreateNetworkInfra.ps1 -edge_cluster_name "edge_cluster_name" -segment_name "segment_name" -dhcp_server_address "172.16.100.2/24" -tier1_gw_name "tier_1_gateway_name" -network "172.16.100.0/24" -gateway "172.16.100.1/24" -dhcp_ranges "172.16.100.50-172.16.100.100"