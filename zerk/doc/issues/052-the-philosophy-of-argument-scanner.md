
## here is a description for all "multi-mode" argument scanner constructions:

  - both because we had to parse the operation name off the ARGV
    before we could know which operation we want to build the
    adaptation for AND because it's more explicit, we tell our
    adapter explicitly the path to the backend operation we are
    calling with `front_scanner_tokens`.

  - each `subtract_primary` has the effect of making that primary
    not settable by the CLI. in most cases we provide a "fixed"
    value for it that to the backend is indistinguishable from a
    user-provided value.

    (note for later: the way we used to do this in [br] was awful)

  - finally with `user_scanner` we pass any remaining non-parsed
    ARGV (which, of course, is written in a "CLI way"). the adapter
    attempts to make the underlying user arguments available to the
    operation for it to read in an "API way" with name convention
    translation as appropriate.
