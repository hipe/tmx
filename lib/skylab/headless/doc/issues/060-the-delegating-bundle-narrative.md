# the delegating bundle narrative :[#060]

## :#storypoint-005 introduction

### an aversion to delegation

we didn't like the idea of delegation at first. we thought that too much
delegation was a design smell. yes "train wrecks" of method chaining are
just as bad if not worse, but bear with us:

let the "delegatee" be the thing that is delegated to; that is the "instream"
object, serivice, method whatever it is that posesses the implementation of
the desired behavior or object. and let the "delegator" be the thing that
delegates, the "façade" for the delegatee.

the potential smell with the delgator pattern is that it broadens too much
the interface of the delegator. it smells of a violation of the SRP
("single responsibility principle", attributed by [#sl-120] Martin to the
original authors): when you delegate you add to the scope of things that your
object does (or merely gives the appearance of doing); which can be a bad
thing in itself.

granted this glosses over all kinds of detail that may lay behind the
delegation, like maybe you are just delgating privately as an implementation
detail rather than adding to your object's public interface; but it is then
debatable whether private delgation should be a thing at all.

we may develop this idea further on, but let it just be a thorn in your side
for now as we continue glibly with the world's perfect delegation DSL.



### what it's good for & why it's here

we do however feel that the façade pattern when used alone can be a good
thing. maybe that is the point. this DSL is a crucial underpinning to our
all important [#067] client services facility, which in turn is a crucial
underpinning to the [#010] client tree model, which is basically what
headless's entire existence consists of.



### quick history

in its first inception this was a three-line implementation meant to be a
slight improvement on the syntax of a popular solution for delegating from out
in the wild. it was arguably an improvement more for what it didn't do rather
than what it did do.

that three line implementation was then moved here and merged in with this
kingdom of complexity you see before you.



### :#storypoint-025 an introduction to the shallow node

the "shallow node" (`Headless::Delegating`) constitutes the implementation of
the 90% use-case for delegation in contemporary new code. primarily we see
(and should see) this distribution limited to the short implementations of
"client services" nodes and the like for reasons explained in the into.

specifically when you enhance a class with the "employment brackets" of
`Delegating[]` with no arguments (except the mandatory first arg, the client)
what you get is an enhancement of the client itself to declare its own
delegations. this comes in the form of two private-but-API-public methods:
`delegate` and `delegating`. the former is for simple delegations (and imagine
it has the same syntactics as the `attr_reader` stdlib method). the latter
is for non-simple delegations.

furthermore your client will get the public refelction methods of the module
methods module. note that `members` is one of these currently. we would warn
you to watch for name collisions with this popular method name, but your
delegator should be doing little else than delegating, for reasons described
in the intro to this article; hence name collisions shouldn't (and we
literally mean "shouldn't") be an issue.

as for the "non-simple" delegations mentioned above, the specs should serve
as the authoritative reference for all the available sub-features of a
delegation; but for a sneak peek, these are probably things like:

  • specify that the delegation result is conditionally `nil` with `if`
  • specifiy which of several delegatees to use with `to`
  • specify a different method name to send to the delegatee with `to_method`
  • specify a simple additive, pattern-based method name transformation that
     determines the delegatee send-method name with `with_infix`, `with_suffix`



## :#storypoint-125

because the syntax-point for method names is necessarily wide open, in order
to parse for method names as we do "normally", we must require that some
modifiers ("sub-phrases") were parsed, otherwise under composition we may
accidentally swallow a term intended for the next phrase of the next bundle.

consider:

    Magic_Foo[ self, :delegating, :with_prefix, :x, :foo, :bar ]

the interpreter will correctly accept 'foo' as a method name, but should
it spin back around and accept 'bar' as a simple delegator? no. it should
stop and assume that that term is intended for another bundle.

but:

    Magic_Foo[ self, :delegating, :to, :wiz, :x, :to, :waz, :y, :bar ]

the interpreter will swallow both 'x' and 'y', but still leave 'bar'.

also, if an array term is on deck we will swallow that:

    Magic_Foo[ self, :delegating, %i( x y ), :bar ]

the interpreter will make simple delegators out of 'x' and 'y', and stop
at the empty space before 'bar' as in all the other examples.

composition with ths interpreter is not future-proof, because the syntax
could add new modifier phrases at any time and as a result swallow more in
the future than it does now. but this caveat is probably true for any bundle
we put under composition insomuch as all bundles have mutable syntax.



## :#storypoint-505 an introduction to the deep node

this node specifically implements all of the 'delegating'-related needs not
covered in the headles core node. the sub-facilities not covered there are
specifically any of the facilities that are reached by providing iambic
arguments to the brackets ("employement") method (`Headless::Delegating[..]`).

we typically leverage the 'delegating' facility through the DSL methods
`delegate` and `delegating` because by and large we use delegation when
modeling "client services". this activity has such a narrow and consistent
use-case that we break the tradition of favoring iambics for DSL's - in this
case the old fasion module-methods-style DSL is better. since as explained
in the intro we think that this use-case is by far a more often justifiable
use of the delegation pattern than other use-cases, the inner mechanics of
delegation have evolved around this.

for those cases when you are not making a "client services" façade and you
still want to use this delegator facility, *and* you don't want to pull in
the module-methods-based DSL in whole-hog, the same DSL is available in
iambic form. the thin layer of implementation necessary for this is here in
the deep node.
