# intro to slowie :[#025]

years (and years and years) after its birth as the "test all" script,
it's getting this rebranding an overhaul. remarkably it hasn't had an
introduction until now?

objective and scope: this main purpose is to *facilitate* running
test at the macro-level.

it is *not* however, a standalone test runner (for now). rather it's
an API designed for other clients to use to invoke tests.

this is why it has only API and not CLI interface.

its utility is largely defined by its operations.

the cheeky name is meant to balance out "quickie". for now they are
kept as separate sub-projects so that quickie can remain stable to
help test slowie, but ultimately they could be merged..
