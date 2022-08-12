####GET THE TIER 1 ROUTER ID######

param ($tier_1_name)



$SECPASS = ConvertTo-SecureString '' -AsPlainText -Force
$CRED = New-Object System.Management.Automation.PSCredential ('', $SECPASS)




####Criar o DHCP config#####
$Url = "https://nsxtmanager.home.lan/policy/api/v1/infra/tier-1s/"+$tier_1_name

$headers = @{
    'Content-Type' = 'application/json'
}


#Invoke-RestMethod -Method 'PUT' -Uri $Url -Credential $CRED -Body $Body -Authentication "Basic" -SkipCertificateCheck -Headers $headers

try {
  #$web_request = Invoke-WebRequest -Method 'PUT' -Uri $Url -Credential $CRED -Body $Body -Authentication "Basic" -SkipCertificateCheck -Headers $headers
  $web_request = Invoke-RestMethod -Method 'GET' -Uri $Url -Credential $CRED -Authentication "Basic" -SkipCertificateCheck -Headers $headers
  #$web_request
  return $web_request.unique_id
 
    # This will only execute if the Invoke-WebRequest is successful.
    #$StatusCode = $web_request
}
catch
{
    Write-host "Request failed"
    $StatusCode = $_.ErrorDetails.Message
    $StatusCode |ConvertFrom-Json |Select -ExpandProperty error_message
    #$_.Exception
}


