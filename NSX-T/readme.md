## Powershell code for consuming NSX-T API (Applies to NSX-T 3.2) <br />
This includes a powershell module that can be used to create a NSX-T segment and DHCP configuration, to be used as DHCP server for VMs.<br />
The module uses several functions to make several API calls. <br />
The script: CreateNetworkInfra imports the module and creates the required network configurations.
<br />

Isolated scripts are not fully functional, but regarding API calls if the request body is correctly configured those work as expected.


### How to use the powershell module: CreateNetworkInfra <br/>

#### Requirements:
- A json config file (named info.json) that must include, and in the example format:
    - NSX-T admin user
    - NSX-T password
    - NST-T transport zone ID

#### Example format info.json:
```json
{
    "username": "",
    "password": "",
    "transport_zone":""
}
```
<br/>

Is also required a pre-configured Tier-1 Gateway (the module doesn't creates this component).

#### Run the command:

.\CreateNetworkInfra.ps1 -edge_cluster_name "edge_cluster_name" -segment_name "segment_name" -dhcp_server_address "172.16.100.2/24" -tier1_gw_name "tier_1_gateway_name" -network "172.16.100.0/24" -gateway "172.16.100.1/24" -dhcp_ranges "172.16.100.50-172.16.100.100"

<br/>

#### Run the command to create a isolated segment (just input the segment name as mandatory parameter)
.\CreateNetworkInfra.ps1 -segment_name "segment_name" 

<br/>


