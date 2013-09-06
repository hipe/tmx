# why use private methods block?

ruby doesn't apply any previous `private` declaration (call) to methods that
are created "dynamically" with e.g `define_method`. if you have the special
case of a module that needs (or wants) some group of its methods to be private
and of that group more than one is generated dynamically, then this is the
time to use a `private_methods` block.

in the case of expression agents in practice many of its business methods are
created dynamically, e.g by currying stylizers or the like. as a matter of
design we don't like the business methods of expression agents to be public
[#fa-052]. this is why you may see expression agents defining its methods
in a private methods block.

the above has a side-benefit of indexing all the business methods. you may
see this turn into an expression agent DSL method of its own.
