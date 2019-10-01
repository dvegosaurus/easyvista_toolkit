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
    [cmdletbinding()]
    param()
    
    if (!($Global:EZVContextFunctionHasRun)){throw "Please run the set-EZVContext cmdlet prior to running this one"}

    $Endpoint = "requests"
    $uri =  "$Global:EZVcompleteURI$Endpoint"
    $data = Invoke-RestMethod -uri "$Global:EZVcompleteURI$Endpoint" -Method GET -Headers $Global:EZVheaders
    $data.records
}

function get-EZVusers
{
    [cmdletbinding()]
    param()
    $Endpoint = "employees"
    if (!($Global:EZVContextFunctionHasRun)){throw "Please run the set-EZVContext cmdlet prior to running this one"}
    $data = Invoke-RestMethod -uri "$Global:EZVcompleteURI$Endpoint" -Method GET -Headers $Global:EZVheaders
    $data.records
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
        [parameter(mandatory=$true)]
        [string]$identification,
        [parameter(mandatory=$true)]
        [string]$lastname,
        [parameter(mandatory=$true)]
        [string]$login,
        [parameter(mandatory=$true)]
        [string]$phone,
        [parameter(mandatory=$true)]
        [string]$mail,
        [parameter(mandatory=$true)]
        [string]$entrydate
    )

    if (!($Global:EZVContextFunctionHasRun)){throw "Please run the set-EZVContext cmdlet prior to running this one"}
    if ($sandbox)
    {$restpoint = "/api/v1/50005/employees"}
    else 
    {$restpoint = "/api/v1/50004/employees"}

    $uri = $url+$restpoint
    $body = [PSCustomObject]@{
        employees = @(
            @{
            identification      = "toto"
            last_name           = $lastname
            login               = $login
            phone_number        = $phone
            e_mail              = $mail
            begin_of_contract   = $entrydate
            }
        )
    } | ConvertTo-Json

    # send the request
    Invoke-RestMethod -Headers $headers -uri $uri -Method POST -Body $body -ContentType "application/json"

}

function new-EZVticket # work in progress
{
    [cmdletbinding()]
    param(
        [parameter(mandatory=$true)]
        [string]$origin,
        [parameter(mandatory=$true)]
        [string]$description,
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
    $body = [PSCustomObject]@{
        employees = @(
            @{
            identification      = "toto"
            }
        )
    } | ConvertTo-Json
    # send the request
    Invoke-RestMethod -Headers $headers -uri $uri -Method POST -Body $body -ContentType "application/json"

}
