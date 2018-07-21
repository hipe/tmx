# experimental conventions

## experimental new provision: stack countdown number as testpoint identifier :[#here.B]

our rough roadmap stack file thing (TODO.stack) consists of a stack of items
where:
  - each item generally represents a task and/or goals and
  - the items are placed in a designed, "regression-friendly" order.

of this stack, certain of its items near the top (actually the bottom of the
file) may have an "identifier integer" next to it. (we might start calling
these "key features".)

you might expect that these items (ordered in the expected order of their
execution) would be numbered in the traditional way, with '1' being the first
item to do, '2' being the second and so on. but instead, we start them from
some negative number (say '-5' if we had 5 overall items) and then we
procede down the stack towards '-1', our goal item.

the advantage of this convention is that you automatically know at a glance
how far the particular item is from the endgoal item. for contrast, numbering
the items in the traditional way tells you how far the item is from the
starting point. for whatever reason, it's more useful to us to know how
close we are to finishing rather than to know how long it's been since we've
started.

  - (we use the minus sign in part as a reminder that this counter-intuitive
    ordinal convention is at play. but note the item numbers still procede
    in ascending order, it's just that their absolute values do not.)

so anyway, as a new experiment with this test suite and others in this
cluster to follow, experimentally a sub-leg of our "coverpoint numberspace"
will draw from these numbers (sort of).

  - in participating examples we will use `X` instead of `1` so that
    we don't use real coverpoint references (present or future).

  - let `#coverpointX` be the major numberspace. (that's `1`, not `2` etc.)

  - under that numberspace, for each "key feature" that you need a
    coverpoint for (there should be at least one coverpoint per feature),
    take the absolute value of the identifier integer (so `5` for `-5`)
    and use that number as the minor number in the coverpoint. so

        `#coverpointX.6` for item `-6`
        `#coverpointX.5` for item `-5`

    and so on.




## (document-meta)

  - #born.
