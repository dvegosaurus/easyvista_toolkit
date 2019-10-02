# easyvista POSH toolkit
This is a set of functions to interact with easyvista's rest API using powershell.

## Changelog
All notable changes to this project will be documented in this file.

### [Unreleased]
- User Creation:
    - In progress (60%)
- Tickets Creation:
    - In progress (50%)
- Error management in functions

*Note: error management will be based on http return codes, for now I'm focusing on getting the functions to work and understanding the API*

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
