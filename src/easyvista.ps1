function get-EZVDepartments
{
    [cmdletbinding()]
    param(
    [parameter(mandatory=$false)]
    [string]$filter,
    [parameter(mandatory=$false)]
    [string]$maxrows = 100
    )
    
    if (!($Global:EZVContextFunctionHasRun)){throw "Please run the set-EZVContext cmdlet prior to running this one"}
    $Endpoint = "Departments"
    $uri =  "$Global:EZVcompleteURI$Endpoint"+"?max_rows=$maxrows"
    $data = Invoke-RestMethod -uri $uri -Method GET -Headers $Global:EZVheaders | select -ExpandProperty records | where {$_.DEPARTMENT_PATH -match $filter}
    $data
}

function get-EZVLocations
{
    [cmdletbinding()]
    param(
    [parameter(mandatory=$false)]
    [string]$filter,
    [parameter(mandatory=$false)]
    [string]$maxrows = 100
    )
    
    if (!($Global:EZVContextFunctionHasRun)){throw "Please run the set-EZVContext cmdlet prior to running this one"}

    $Endpoint = "Locations"
    $uri =  "$Global:EZVcompleteURI$Endpoint"+"?max_rows=$maxrows"
    $data = Invoke-RestMethod -uri $uri -Method GET -Headers $Global:EZVheaders  | select -ExpandProperty records | where {$_.LOCATION_PATH -match $filter}
    $data
}

function get-EZVCatalogRequests
{
    [cmdletbinding()]
    param()
    
    if (!($Global:EZVContextFunctionHasRun)){throw "Please run the set-EZVContext cmdlet prior to running this one"}

    $Endpoint = "catalog-requests"
    $uri =  "$Global:EZVcompleteURI$Endpoint"
    $data = Invoke-RestMethod -uri "$Global:EZVcompleteURI$Endpoint" -Method GET -Headers $Global:EZVheaders
    $data.records
}

function get-EZVRequests
{
     param(
    [parameter(mandatory=$false)]
    [string]$rfc, # filtering on RFC
    [parameter(mandatory=$false)]
    [string]$maxrows = 100,
    [parameter(mandatory=$false)]
    [string]$recipient,
    [parameter(mandatory=$false)]
    [string]$requestor
    )
    
    if (!($Global:EZVContextFunctionHasRun)){throw "Please run the set-EZVContext cmdlet prior to running this one"}
    if ($maxrows -eq 100){Write-Warning "Only first $maxrows will be returned. Use -maxrows to increase the number."}
    $Endpoint = "requests"

# create filtering scriptblock
    if ($recipient){$recipientString = ('$_.recipient.last_name -match "{0}"') -f $recipient}
    if ($requestor){$requestorString = ('$_.requestor.last_name -match "{0}"') -f $requestor}

    if ($recipient){[scriptblock]$filter = [ScriptBlock]::Create($recipientString)}
    if ($requestor){[scriptblock]$filter = [ScriptBlock]::Create($requestorString)}
    if ($recipient -and $requestor)
    {
        [scriptblock]$filter = [ScriptBlock]::Create($recipientString +" -and"+$requestorString)
    }

    if ($filter)
    {
# create and run the rest request
    $uri =  "$Global:EZVcompleteURI$Endpoint"+"?max_rows=$maxrows"
    $data = Invoke-RestMethod -uri $uri -Method GET -Headers $Global:EZVheaders | select -ExpandProperty records | Where-Object -FilterScript  $filter
    $data
    }
    elseif($rfc)
    {
# create and run the rest request
    $uri =  "$Global:EZVcompleteURI$Endpoint"+('?search=rfc_number~"*{0}*"&max_rows={1}' -f $rfc,$maxrows)
    $uri
    $data = Invoke-RestMethod -uri $uri -Method GET -Headers $Global:EZVheaders | select -ExpandProperty records 
    $data
    }
    else
    {
# create and run the rest request
    $uri =  "$Global:EZVcompleteURI$Endpoint"+"?max_rows=$maxrows"
    $data = Invoke-RestMethod -uri $uri -Method GET -Headers $Global:EZVheaders | select -ExpandProperty records 
    $data
    }

}


function get-EZVusers
{
    [cmdletbinding()]
    param(
    [parameter(mandatory=$false)]
    [string]$filter,
    [parameter(mandatory=$false)]
    [string]$maxrows = 100
    )

    # check if context was set
    if (!($Global:EZVContextFunctionHasRun)){throw "Please run the set-EZVContext cmdlet prior to running this one"}
    if ($maxrows -eq 100){Write-Warning "Only first $maxrows will be returned. Use -maxrows to increase the number."}

    $Endpoint = "employees"
    $uri =  "$Global:EZVcompleteURI$Endpoint"+"?search=last_name~$filter*&max_rows=$maxrows"
    $data = Invoke-RestMethod -uri $uri  -Method GET -Headers $Global:EZVheaders | select -ExpandProperty records | where {$_.last_name -match $filter}
    $data
}

function set-EZVContext
{
<#
.SYNOPSIS
Define accessible variable for other cmdlet.
.DESCRIPTION
This cmdlet will create a set of global variables accessible for other cmdlet in the module. Since those global variables will be needed to use autocompletion in other cmdlet, it is mandatory to run prior to any other EZV cmdlet otherwise they will return an error.
.EXAMPLE
set-EZVContext -username user -password 123456 -uri https://my.easyvista.com -database production
.INPUTS
Inputs to this cmdlet (if any)
.OUTPUTS
Output from this cmdlet (if any)
.NOTES
General notes
.COMPONENT
The component this cmdlet belongs to
.ROLE
The role this cmdlet belongs to
.FUNCTIONALITY
   The functionality that best describes this cmdlet
#>
    param(
        [parameter(mandatory=$true)]
        [string]$username,
        [parameter(mandatory=$true)]
        [string]$password,
        [parameter(mandatory=$true)]
        [string]$uri,
        [parameter(mandatory=$true)]
        [validateset("sandbox","production")]
        [string]$database
    )

# convert login:password to an encrypted string
    $base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $username,$password)))
    $headers = @{
        ContentType = "application/json"
        Authorization= ("Basic $base64AuthInfo")
    }
    # creating global variable, acccessible to other cmdlet (see ADR 0001)
    $global:EZVheaders = $headers 
    $global:EZVuri     = $uri
    switch ($database)
    {
        "sandbox"     {$global:EZVBase = "50005"}
        "production"  {$global:EZVBase = "50004"}
    }
    $Global:EZVcompleteURI = $uri+"/api/v1/"+$global:EZVBase+"/"
    $Global:EZVContextFunctionHasRun = $true # will provide an easy check for other functions
    return $headers
}

function new-EZVuser # work in progress
{
    param(
        [parameter(mandatory=$false)]
        [ArgumentCompleter({
            param ($commandName,$parameterName,$wordToComplete,$commandAst,$fakeBoundParameters)
            $Endpoint = "departments"
            $uri =  "$Global:EZVcompleteURI$Endpoint"
            Invoke-RestMethod -Headers $global:EZVheaders -uri $uri -Method GET |
            select -ExpandProperty records | 
            select -ExpandProperty DEPARTMENT_PATH | where {$_ -match $wordToComplete}
        })]
        [string]$departmentPath,
        [parameter(mandatory=$false)]
        [string]$endOfContract,
        [parameter(mandatory=$false)]
        [string]$beginOfContract,
        [parameter(mandatory=$false)]
        [string]$lastName,
        [parameter(mandatory=$false)]
        [string]$eMail,
        [parameter(mandatory=$false)]
        [string]$phoneNumber,
        [parameter(mandatory=$false)]
        [ArgumentCompleter({
            param ($commandName,$parameterName,$wordToComplete,$commandAst,$fakeBoundParameters)
            $Endpoint = "locations"
            $uri =  "$Global:EZVcompleteURI$Endpoint"+"?max_rows=4000"
            $results = Invoke-RestMethod -Headers $global:EZVheaders -uri $uri -Method GET |
            select -ExpandProperty records | 
            select -ExpandProperty LOCATION_PATH | where {$_ -match $wordToComplete} | foreach {"'"+$_+"'"}
            $results
        })]
        [string]$locationPath
    )

    Write-Verbose $locationPath
    # check if necessary variable have been set
    if (!($Global:EZVContextFunctionHasRun)){throw "Please run the set-EZVContext cmdlet prior to running this one"}

    # get location HREF
    $locationEndpoint = "locations"
    $uri =  "$Global:EZVcompleteURI$locationEndpoint"+"?max_rows=4000"
    $location = Invoke-RestMethod -Headers $global:EZVheaders -uri $uri -Method GET | select -ExpandProperty records | where {$_.LOCATION_PATH -eq $locationPath}
    $locationID = Invoke-RestMethod $location.HREF -Headers $Global:EZVheaders | select -ExpandProperty LOCATION_ID

    # get department HREF
    $departmentEndpoint = "departments"
    $uri =  "$Global:EZVcompleteURI$departmentEndpoint"
    $departmentID = Invoke-RestMethod -Headers $global:EZVheaders -uri $uri -Method GET | select -ExpandProperty records | where {$_.DEPARTMENT_PATH -eq $departmentPath}  | select -ExpandProperty DEPARTMENT_ID

    $Endpoint = "employees"
    $uri = "$Global:EZVcompleteURI$Endpoint"
    
    $PSO = [PSCustomObject]@{
        $Endpoint = @(
            @{}
        )
    }

    # add member to the PSO hashtable if they were passed as parameter
    if ($departmentPath)  {$PSO.$endpoint[0] += @{"DEPARTMENT_ID"        = $departmentID}}
    if ($locationPath)    {$PSO.$endpoint[0] += @{"LOCATION_ID"          = $locationID}}
    if ($endOfContract)   {$PSO.$endpoint[0] += @{"END_OF_CONTRACT"   = $endOfContract}}
    if ($beginOfContract) {$PSO.$endpoint[0] += @{"BEGIN_OF_CONTRACT" = $beginOfContract}}
    if ($lastName)        {$PSO.$endpoint[0] += @{"LAST_NAME"         = $lastName}}
    if ($eMail)           {$PSO.$endpoint[0] += @{"E_MAIL"            = $eMail}}
    if ($phoneNumber)     {$PSO.$endpoint[0] += @{"PHONE_NUMBER"      = $phoneNumber}}
   
    $body = $PSO | ConvertTo-Json

    Write-Verbose $body
    # send the request
    Invoke-RestMethod -Headers $global:EZVheaders -uri $uri -Method POST -Body $body -ContentType "application/json"

}

function new-EZVticket # work in progress
{
    [cmdletbinding()]
    param(
        [parameter(mandatory=$true)]
        [string]$description,
        [parameter(mandatory=$true)]
        [string]$recipientName,
        [parameter(mandatory=$true)]
        [string]$requestorName,
        [parameter(mandatory=$true)]
        [ArgumentCompleter({
            param ($commandName,$parameterName,$wordToComplete,$commandAst,$fakeBoundParameters)
            $Endpoint = "catalog-requests"
            $uri =  "$Global:EZVcompleteURI$Endpoint"
            Invoke-RestMethod -Headers $global:EZVheaders -uri $uri -Method GET |
            select -ExpandProperty records | 
            select -ExpandProperty CATALOG_REQUEST_PATH | where {$_ -match $wordToComplete}
        })]
        [string]$catalog
    )

    # check if necessary variable have been set
    if (!($Global:EZVContextFunctionHasRun)){throw "Please run the set-EZVContext cmdlet prior to running this one"}

    $Endpoint = "requests"
    $uri = "$Global:EZVcompleteURI$Endpoint"

    # finding the catalog ID based on its name
    $catalogEndpoint =  "catalog-requests"
    $catalogID = Invoke-RestMethod -uri "$Global:EZVcompleteURI$catalogEndpoint" -Method GET -Headers $Global:EZVheaders | select -ExpandProperty records | where {$_.CATALOG_REQUEST_PATH -match $catalog } 
    $catalogGUID = Invoke-RestMethod -uri $catalogID.HREF -Headers  $Global:EZVheaders | select -ExpandProperty CATALOG_GUID
    $body = [PSCustomObject]@{
        $Endpoint = @(
            @{
            recipient_Name = $recipientName
            requestor_Name = $requestorName
            description    = $description
            catalog_guid   = $catalogGUID -replace '{|}',''
            }
        )
    } | ConvertTo-Json

    Write-Verbose $body
    # send the request
    Invoke-RestMethod -Headers $global:EZVheaders -uri $uri -Method POST -Body $body -ContentType "application/json"

}


# new-EZVticket -recipientName "RGOU_test1" -requestorName "RGOU_test" -description "this is a test incident created while writing a script" -catalog "service/toto/creation de truc" -Verbose
