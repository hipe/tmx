# the interpretation of operation execution results :[#025]

## status of this documents

this is a "brainstorm" - it is not even a specification or a draft for a
specification..




## scope & objective

this applies to all three of the "bundled modalities" of zerk (API,
niCLI and iCLI). the focus of this discussion is towards a specification
of how [ze] will interpret results from operation executions.




## modality-agnostic result interpretation. ( the "no-API" result shape )

experimentally, there is no modality agnostic API governing the
interpretation of results from operations. this is in contrast to a pre-
[#009]  (rewrite) of iCLI, which had the boolean-ish-ness of the result
interpreted to indicate the success or failure of the operation (and
when true-ish the result was assmed to be a [#ca-004] knownness wrapping
the (any) successful result).




### implications of this - the ideal applicability

this choice is for the readability and intuitive-ness of specifying that
the operation can result in any value and there is no general API
governing its interpretation. the result shape for the operation should
be whatever business-specific shape makes sense for the operation (for
example if the operation's successful result is a count, then it should
be able to result in a plain old integer; if boolean, boolean; etc).

on the one hand, this is choice "shines" most for when using a [ze]-
generated API: there is no (er) API between the operation implementer
and the operation client in regards to what the result it, which makes
for readable, intuitive code and less API to have to think about.

on the other hand, this makes things more challenging for implementing
the other two bundled, generated modalities:




### implications of this - the challenges

this "no-specification" specification is after two previous
complete-rewrite drafts of this same document. as mentioned above, at
least one version of the iCLI applied special semantics (i.e had special
interpretations) for the results from operations.

experimentally we are now shedding this API, with the most salient
effect from this being this:

the result shape cannot be used as a "channel" to indication whether the
operation succeeded or failed...
