# Using Global variables

date : 2019/10/01

## Status

accepted

## Context

We want to use autocompletion in some functions to make them more usable. Because the easyvista rest API relies on GUID for some
parameters we need to be able to query within in the functions parameters.

## Decision

We will use global variable name $EZV<variablename> set by a function that will define the context of execution for the other 
functions (easyvista URI, Headers ... )

## Consequences

### Pros
    - cmdlet will be easier to use
### Cons
    - global variable with the same might allready exist

