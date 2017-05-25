# the proc as action narrative :[#052]


## catalyst & objective

for the simplest of actions, needing to subclass (or otherwise
implement) an action class can feel like overkill. this proxy node
allows you to place an ordinary platform proc in the place of where you
would normally put an action class, and allows it to integrate with your
application pretty much "as expected" (for our defintion of what is
expected).




## premise

the platform proc (and its built-in reflection API) has considerable
expressive power in its context:

  • we can infer an action name from the const the proc is stored under
    (but note the proc itself will not tell us this - we have to remember
     the const we used to acces it.)


  • from the platform `parameters` method we can get a reflective list of
    each formal argument to the proc, along with whether it is:

      `req` | `opt` | `rest` | `block`

    from these we can mock-up a would-be formal properties structure,
    each formal property of which can have inferred for it:

      • its name
      • whether or not it is required -or- whether it is a 0..many


  • the proc itself can hold the logic for the simplest of actions.




## caveats

in practice, the simplest of solutions (maybe half the time) get
re-written to scale up to a less-than-simplest-but-still-simple
solution (for there is a lot that an action sub-class can express that
is not expressed in the above.

we want to be sure that an upgrade path is clear for every
proc-as-action that you implement; because often you will end up walking
this path.




## contract ("signature classification")

### emitting possible events from your proc

if from your proc you want to emit possible events, accept a block
argument in the arguments to your proc. use *this* proc as an
"on event selectively" proc to emit the events.




### accessing your model tree & resources (:#mechanic-1)

somewhat awkwardly but as a compromise between simplicity and power, if
your proc will want to access pretty much anything having to do with the
rest of your application (or resources that it, in turn, can access):

  • accept as the last non-block declared formal argument either a
    `rest` or a `req`-style parameter. if you accept no non-block
    arguments, or your last non-block argument is `opt`, you will
    not engage the below described mechanic.

if your proc opts-in to this arrangement per the above rule:

  • the proc's (business-minded) inferred formal properties will
    exclude this parameter.

  • your proc when invoked will then be passed *some* object that
    can be used to access for e.g your application's kernel
    (probably the proc-as-bound proxy).

because this is still :+#experimental, details may change; but the spirit
of this mechanic will likely endure.
_
