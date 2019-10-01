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

function new-EZVuser
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

function new-EZVticket
{
    param(
        [parameter(mandatory=$true)]
        [string]$origin,
        [parameter(mandatory=$true)]
        [string]$description,
        [parameter(mandatory=$true)]
        [ArgumentCompleter({
            param ($commandName,$parameterName,$wordToComplete,$commandAst,$fakeBoundParameters)
            $uri = "https://prolival.easyvista.com/api/v1/50005/catalog-requests"   # NEED TO FIX THAT SHIT. GLOBAL VARIABLE ?
            Invoke-RestMethod -Headers $global:headers -uri $uri -Method GET |
            select -ExpandProperty records | 
            select -ExpandProperty CATALOG_REQUEST_PATH | where {$_ -match $wordToComplete}
        })]
        [string]$catalog
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