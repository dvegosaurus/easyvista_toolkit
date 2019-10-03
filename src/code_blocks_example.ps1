#$username = "xxxxxx"         # replace with actual login or encrypt outside the script
#$password = "xxxxxxxxxxxxxxxxx"  # replace with actual password or encrypt outside the script



$uri = "https://my.easyvista.com/api/v1/50005/employees"
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

# list tickets
$uri = "https://my.easyvista.com/api/v1/50005/requests"
$data = Invoke-RestMethod -Headers $headers -uri $uri -Method GET 
     # get catalog_request by customer (to get catalog_id)
$data.records.catalog_request | where {$_.CATALOG_REQUEST_PATH -match "something"}

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

# show a specific ticket
$uri = "https://my.easyvista.com/api/v1/50005/requests/i190925_004"
Invoke-RestMethod -Headers $headers -uri $uri -Method GET 


# to find a incident Catalog_guid :
# 1. Find an incident matching your neeed
# 2. Show the incident "https://my.easyvista.com/api/v1/50005/requests/i190925_001"
# 3. look at the SD_CATALOG_ID
# 4. use the SD_CATALOG_ID to grab the catalog guid : "https://my.easyvista.com/api/v1/50005/catalog-requests/5086"


# show ticket description :
# note that the fucking request is on COMMENT!!!!!!

$uri = "https://my.easyvista.com/api/v1/50005/requests/i190925_004/comment"
Invoke-RestMethod -Headers $headers -uri $uri -Method GET 

##### Dynamic Scriptblock
$string = "get-process"
$filterscript = [ScriptBlock]::Create($string)
$filterscript
$filterscript = [ScriptBlock]::Create($filterscript.ToString() + " powershell")
$filterscript
& $filterscript
