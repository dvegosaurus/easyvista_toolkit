# Using Global variables

date : 2019/10/01

## Status

accepted

## Context

We want to use autocompletion in some functions to make them more usable. Because the easyvista rest API relies on GUID for some
parameters we need to be able to query their friendly name within in the functions parameters.

## Decision

We will use global variable name *$EZVvariablename* set by a function that will define a context of execution for the other 
functions (easyvista URI, Headers ... )

## Consequences

### Pros
    * cmdlet will be easier to use
### Cons
    * global variable with the same might allready exist. [^1]

[^1] : since this will be used in controlled environment this should not be a big issue.