# easyvista POSH toolkit
This is a set of functions to interact with easyvista's rest API using powershell.

## Changelog
All notable changes to this project will be documented in this file.

### [Unreleased]
- User Creation:
    - In progress (60%)
- Tickets Creation:
    - In progress (80%)
- Error management in functions

*Note: error management will be based on http return codes, for now I'm focusing on getting the functions to work and understanding the API*

## [0.0.4] - 2010/10/04
### Changed
- Improved new-EZVRequest:
    - Added autocomletion on recipient parameter
    - Request should now be created with the proper path location
        - only works if the recipient exist, hence the need for autocompletion
    - removed the requestorname parameter
        - easyvista doesn't take it into account and use instead the login in the headers

## [0.0.3] - 2010/10/03
### Changed
- Improved get-EZVRequests and get-EZVUsers functions:
    - Added a maxrows parameter to limit the numbers of results
        - Done to bypass the default 100 results builtin the easyvista API
    - Added filtering:
        - *-filter* parameter for get-EZVUsers
        - *-rfc,-requestor,-recipient* for get-EZVRequests

## [0.0.2] - 2010/10/03
### Added
- Get functions for:
    - Locations (get-EZV-locations)
    - Departments (get-EZV-departments)
- basic working functions to:
    - create a user
    - create a request

## [0.0.1] - 2010/10/01
### Added
- Basic Get functions needed to build the rest of the module
    - Get-EZVUsers
    - Get-EZVRequests
    - Get-EVZCatalogRequests
- Function to set the global variables used by other functions
    - see ADR 0001_GlobalVariables
