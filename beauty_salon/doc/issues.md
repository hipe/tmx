[#050] #open remaining CLI/API (UI) issues with #crazy-town

[#049] #open flicker as documented

[#048]       #parent-node: [#010] procedurally find the smaller methods
             (cross-referenced only in [dt])

[#047] #small #open track many places where documentation is known to be
             in need of freshening up

[#046] #open remaining CLI/API (UI) issues with #crazy-town

[#045] #open we have no intention of making #crazy-town platform language
             complete until quite a ways later. our current intention is
             to get it to work for our own corpus as a refactoring tool.
             when we publish this we will strive for some kind of "completeness"

             a finishing point of this *might* be (in a single commit) to
             sunset all references of ~"what we used to do in the old days"

[#044] #open use case in [ze]
             [#here.2] another one in [ze]

[#043] #open track mounting executables (lost when wean off [br])

[#042]       #crazy-town "musings" - assorted (voluminous) documentation

[#041]       #crazy-town thing.dot

[#040]       all the letters of the alphabet ..

[#039]       #case-study: how does my future self think this should be
             refactored? (in [mt])
[#038]       precedence rules for logical taxonomies ..
[#037]       n.c for filenames ..
[#036]       historic ascii graph (in directory [#034])
             #tombsone - more great ascii art sunsetted [#ts-017]
[#035]       #historic the shell and kernel name convetions ..
[#034]       ascii graphic examples
[#033]       [ word wrap (here) ]
[#032]       name conventions for variables .. #parent-node:[#030]
[#031]       name conventions for methods (adjunct) ..  #parent-node:[#030]
[#030]       name conventions ..
[#029]       name conventions for constants .. #parent-node:[#030]
[#028]       name conventions for functions and methods ..  #parent-node:[#030]
[#026]       unparsing ..

[#025]       #crazy-town implementation ..
             ( #was: #moved-to: [sa] )

[#024] #small #open fix sytax highlighting YUCK so you can use `~>` HEREDOC,
             which in turn will make "line stream via big string" less chunky
             ( #was: #moved-to: [sa] )

[#023]       grammatical symbol ordering rationale ..

             ( #was: ween off of [br]  (this is for tracking related todo's) )
             ( #was: #moved-to: [sa] )

[#022]       mainly, this is to track the document about declared, structural
             grammar symbols. but also:

       #open [#here.E2] get structural, imperative-based declarations in
             that one file to *complement* (not redund) with the main file.

       #open [#here.E] tracks future places to refactor-in (see document)

       #also: this identifier now tracks the relevant node

             ( #was: #moved-to: [sa] )

[#021]       #crazy-town our take on an AST processor ..
             ( #was: #moved-to: [sa] )

[#020] #open #wish: contribute to ragel in this one way
             ( #was: encoding issues with git config ([#ba-064]) )

             :[#here.B]: (in "ragel notes", the dedicated document for this node)

[#019]       the `[*]` task of converting all `Foo_::Lib_::Bar_BAZ[]`
               to `Foo_.lib.bar_BAZ`..
[#018]       [ why we like immutability ]
[#017]       "dreams of unification" is at [#cu-003]

[#016]       conventions for documentation documents ..
             ( #was: the search and replace narrative .. )

[#015]       "ok chains" instead of "begin ; end while nil" hacks
[#014]       #doc-node the `deliterate` utility
[#013]       the problem with functions ..
[#012]       #doc-point "private fold method" defined and explored..

[#011]       #idea - terrible: results of rcov used to eliminate
               branches of unused code from sourcecode, programattically!

       #wish (above, kept as-is for now so we can more easily dig history)

[#010]       sl/test-support/tmpdir is a great subject
             (this has become more generally a #tracking-tag for same.)
             :[#here.B] (in [pl])
[#009]       #backburner unwrap -- terrible idea

[#008]       ( lend & borrow dependency & coverage )
             :[#here.1]:

             ( #was: index all the vectors of `porcelain/test/porcelain_spec.rb` )

             [#here.E] tracks future places to refactor-in (see document)

[#007]       ( intra-subsystem issues )

      #wish [#here.Y] maybe one day resources for replacement expressions

      #wish [#here.W] we might want listy to itself have `to_code` to
            clean up ad-hoc replacement functions

      #open [#here.V] generally, the monolith could still be cleaned up
             and de-redundified with the new Writer class

            [#here.U] as described, we could make the delimiters parser
             be a strong injection point

      #open [#here.T] track all holes in documentation #release

      #open [#here.S] literal string modification will be somewhat broken

      #track [#here.R] regexp escaping

      #open #DRY [#here.Q] string handling and similar is dis-unified

      #small #wish [#here.P] a verbose mode

      #small #open [#here.O] when you're really close to the end, rename
             "callish identifier" as something like "grammar symbol name"

      #open [#here.N]: yikes a sub-sub-division of one of these. for no good
            reason, here we're putting lots of known holes of things we need
            to cover for #unparse. (we didn't need them to be covered to get
            our objective use case.)

            :[#here.N.6]: known hole: string via string on this: `HI = 3..4`

            [#here.N.5]: (see)

            [#here.N.4]: another kind of definition

            [#here.N.3]: one kind of definition

            [#here.N.2]: methods with an `operator` instead of a `name`

            [#here.N.1] (to avoid ambiguity, use this node to reference all of these)

      #small #open [#here.M] maybe one day unify association names

      #small #open [#here.L]: as commented. DigAndChangeTerminal etc may obivate old way

      #small #open [#here.K]: as commented. tons of holes for `_to_friendly_string`

      #small #open #possible-optimization [#here.J]: as commented - we shift an array

      #small #open [#here.I]: as commented. the group name `assignableformlhss`

      #small #open [#here.H]: as commented. do we really want this mlhs group?

             [#here.G]: whether or not "branchiness" should be markup in the
             grammar. that this is a const and not a method is because it's
             20% faster.
             (see also #this-commit message)

      #note [#here.F]: factory pattern is unofficial; clunky.

             [#here.E]: (needs a better home) the main mapping challenge
               this is not just the stuff about plural associations, but
               about whether we will ever support arbitrarily prioritized optionals.

             [#here.D]: the provision that we assert the many things we assert
             of our formal grammar against the actual AST node (tree). things
             like: arity, group, terminal type. (summary: it has a cost but we
             see it as justified to sanity-check our model (grammar))

             [#here.C]: design decision: reports are simple magnetics, not actions

             [#here.B]: tickler: one day #crazy-town target multiple syntax versions

             [#here.A]: the document, which is a very early trace of etc ..

[#006]       2012-10-28 #chore get ideas from skylab.rb, flatten to issues
[#005]       2012-09-02 #feature (:convert => 'this') (to: 'this') (and ..)
[#004]       2012-08-19 #feature be able to break up long lines #tricky
[#003]       2012-08-19 #feature as an excercise of a model transformation (..)
[#002]       2012-08-19 #feature be able to rename a symbol
               (following conventions)
[#001]       #feature 2012-08-19 #feature be able to detect and omit nonzero ranges of
               trailing newlines and whitespace
[#sl-104] 2012-08-18 beauty-salon : a code-molester application #bad-idea
