

$Credential = Get-Credential
$Auth = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($Credential.UserName + ':' + $Credential.GetNetworkCredential().Password))


#$Auth
$RestApiServer = '127.0.0.1:8697'
$BaseUri = "http://$RestApiServer"

$headers = @{}

#uncomment to set sessionkey to header
$headers.Add("Authorization","Basic $Auth")
#uncomment to set sessionkey to header


$headers.Add("Content-Type", "application/vnd.vmware.vmw.rest-v1+json")
$headers.Add("Accept","application/vnd.vmware.vmw.rest-v1+json")   

$vms = Invoke-RestMethod -Uri $BaseUri"/api/vms" -Headers $headers -Method GET 
$aux = $vms |where path -Match "Template"
$id = $aux[0].id
$vm = Invoke-RestMethod -Uri $BaseUri"/api/vms/$id" -Headers $headers -Method GET 
#$vm = Invoke-RestMethod -Uri $BaseUri"/api/vms" -Headers $headers -Method GET 


#$vm.id
#new VM
function CreateVMs() {
    for($i=0; $i -lt 4; $i++){
        $body = @{}
        $body.Add("name","DB0$i");
        $body.add("parentId",$vm.id);
        Invoke-RestMethod -Uri $BaseUri"/api/vms" -Headers $headers -Method POST -body ($body | ConvertTo-Json)
    }
}


function PowerOnVMs(){
    $vms =  Invoke-RestMethod -Uri $BaseUri"/api/vms" -Headers $headers -Method GET 
    $vms = $vms |where path -Match "DB0"

    foreach ($vm in $vms) {
        $id = $vm.id
        $id    
        
        Invoke-RestMethod -Uri $BaseUri"/api/vms/$id/power" -Headers $headers -Method PUT -body on
    }
}

function PowerOffVMs {
    $vms =  Invoke-RestMethod -Uri $BaseUri"/api/vms" -Headers $headers -Method GET 
    $vms = $vms |where path -Match "DB0"

    foreach ($vm in $vms) {
        $id = $vm.id                
        Invoke-RestMethod -Uri $BaseUri"/api/vms/$id/power" -Headers $headers -Method PUT -body shutdown
    }
}

function DeleteVMs {
    $vms =  Invoke-RestMethod -Uri $BaseUri"/api/vms" -Headers $headers -Method GET 
    $vms = $vms |where path -Match "DB0"
    foreach ($vm in $vms) {
        $id = $vm.id                
        Invoke-RestMethod -Uri $BaseUri"/api/vms/$id" -Headers $headers -Method DELETE
    }
}

while ($true)  {
    write-host "1 - Create VMs"
    write-host "2 - Power on VMs"
    write-host "3 - Power off VMs"
    write-host "4 - Delete VMs"
    $option = Read-Host -Prompt 'Choose an option:'


    Switch ($option)
    {
        1 {CreateVMs}
        2 {PowerOnVMs}
        3 {PowerOffVMs}
        4 {DeleteVMs}    
    }
} 
