function new-EZVHeader
{
<#
.Synopsis
   Create a header hashtable to use with other EZV cmdlet
.DESCRIPTION
   Long description
.EXAMPLE
   Create a header hashtable to use with other EZV cmdlet. The password parameter is not
   an encrypted string but is encrypted when creating the header.
.EXAMPLE
   new-EZVHeader -username <username> -password <password>
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
        [string]$password
    )

# convert login:password to an encrypted string
    $base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $username,$password)))
    $headers = @{
        ContentType = "application/json"
        Authorization= ("Basic $base64AuthInfo")
    }
    $global:EZVheaders = $headers # create an global variable accessible to other cmdlet
    return $headers
}

function new-EZVuser
{
    param(
        [parameter(mandatory=$true)]
        [string]$url,
        [parameter(mandatory=$true)]
        [string]$headers,
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
        [string]$entrydate,
        [switch]$sandbox
    )

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
        [string]$url,
        [parameter(mandatory=$true)]
        [string]$headers,
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
        [string]$catalog,
        [switch]$sandbox
    )

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