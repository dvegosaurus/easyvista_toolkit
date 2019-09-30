#$username = "xxxxxx"         # replace with actual login or encrypt outside the script
#$password = "xxxxxxxxxxxxxxxxx"  # replace with actual password or encrypt outside the script

# convert login:password to an encrypted string
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $username,$password)))

# use the encoded string in the header's request
$headers = @{
    ContentType = "application/json"
    Authorization= ("Basic $base64AuthInfo")
}


$uri = "https://prolival.easyvista.com/api/v1/50005/employees"
Invoke-RestMethod -uri $uri -Method GET -Headers $headers

# create user
$body =@"
{
 "employees": [
    {
     "identification": "123458",
     "last_name": "Seagal, Steven",
     "login": "sseagal",
     "phone_number": "+34123456123",
     "e_mail": "sseagal@exemple.com",
     "begin_of_contract": "12/01/2020"
    }
  ]
}
"@

$uri = "https://prolival.easyvista.com/api/v1/50005/employees"
Invoke-RestMethod -Headers $headers -uri $uri -Method POST -Body $body -ContentType "application/json"


# list user
$uri = "https://prolival.easyvista.com/api/v1/50005/employees/14659"
Invoke-RestMethod -Headers $headers -uri $uri -Method GET 

# list tickets
$uri = "https://prolival.easyvista.com/api/v1/50005/requests"
$data = Invoke-RestMethod -Headers $headers -uri $uri -Method GET 
     # get catalog_request by customer (to get catalog_id)
$data.records.catalog_request | where {$_.CATALOG_REQUEST_PATH -match "PROL"}

# list les catégories de ticket
$uri = "https://prolival.easyvista.com/api/v1/50005/catalog-requests"
$data = Invoke-RestMethod -Headers $headers -uri $uri -Method GET 
$data.records | ft

# create ticket
 $body = @"
{
    "requests" :
    [{ 
      "Catalog_guid" : "61E17EFF-5ED7-4B20-B26F-4FAC57555EBC",
      "AssetID" : "",
      "AssetTag" : "",
      "ASSET_NAME" : "",
      "Urgency_ID" : "1",
      "Severity_ID" : "40",
      "External_reference" : "",
      "Phone" : "93-63 - 65-23",
      "Requestor_Identification" : "",
      "Requestor_Mail" : "morley@itassetservices.com",
      "Requestor_Name" : "",
      "Location_ID" : "",
      "Location_Code" : "",
      "Department_ID" : "",
      "Department_Code" : "",
      "Recipient_ID" : "",
      "Recipient_Identification" : "",
      "Recipient_Mail" : "leblanc@itassetservices.com",
      "Recipient_Name" : "",
      "Origin" : "3",
      "Description" : "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
      "ParentRequest" : "",
      "CI_ID" : "",
      "CI_ASSET_TAG" : "",
      "CI_NAME" : "",
      "SUBMIT_DATE" : ""
      }]
}
"@

$uri = "https://prolival.easyvista.com/api/v1/50005/requests"
Invoke-RestMethod -Headers $headers -uri $uri -Method POST -Body $body -ContentType "application/json"

# list les catégories de ticket
$uri = "https://prolival.easyvista.com/api/v1/50005/catalog-requests/27001"
Invoke-RestMethod -Headers $headers -uri $uri -Method GET 


# show a specific ticket
$uri = "https://prolival.easyvista.com/api/v1/50005/requests/i190925_004"
Invoke-RestMethod -Headers $headers -uri $uri -Method GET 


# to find a incident Catalog_guid :
# 1. Find an incident matching your neeed
# 2. Show the incident "https://prolival.easyvista.com/api/v1/50005/requests/i190925_001"
# 3. look at the SD_CATALOG_ID
# 4. use the SD_CATALOG_ID to grab the catalog guid : "https://prolival.easyvista.com/api/v1/50005/catalog-requests/5086"


# show ticket description :
# note that the fucking request is on COMMENT!!!!!!

$uri = "https://prolival.easyvista.com/api/v1/50005/requests/i190925_004/comment"
Invoke-RestMethod -Headers $headers -uri $uri -Method GET 


# list all the incident type
$uri = "https://prolival.easyvista.com/api/v1/50005/catalog-requests"
Invoke-RestMethod -Headers $headers -uri $uri -Method GET |
select -ExpandProperty records | 
select CATALOG_REQUEST_PATH,SD_CATALOG_ID

# how to add autocompletion with a dynamic request
function test
{
    param(
        [ArgumentCompleter({
        param ($commandName,$parameterName,$wordToComplete,$commandAst,$fakeBoundParameters)
        $username = "xxxxxx"
        $password = "xxxxxxx"
        $base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $username,$password)))
        $headers = @{
            ContentType = "application/json"
            Authorization= ("Basic $base64AuthInfo")
        }
        $uri = "https://prolival.easyvista.com/api/v1/50005/catalog-requests"
        Invoke-RestMethod -Headers $headers -uri $uri -Method GET |
        select -ExpandProperty records | 
        select -ExpandProperty CATALOG_REQUEST_PATH | where {$_ -match $wordToComplete}
    })]
    [string]$request
    )
}