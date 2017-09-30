# readme

## provisions & caveats of each of these files

each of these files exists to add coverage to "crazy town" for
grammatical symbols that need to be covered.

it should be safe to add "features" (language feature instances) to
any such file, but don't remove features from it.




## ordering rationale

a grammar is something of a component system, with larger grammatical
symbols being made up of smaller grammatical symbols (non-terminals
being made of up non-terminals and terminals, and so on).

pursuant to our [#ts-001] general ordering rationale, it then follows
that we try to cover the lower-level components earlier, in front of the
larger components (some of which in theory would need to use the smaller
ones in order to effect themselves).

(we deviate from this rubric only to put the "special" and edge cases
at the end, for inexplicable OCD reasons.)

  - literals and assignments
  - control flow
  - begin rescue end
  - method definitions and method calls
  - modules and classes
  - special and edge

(note: #spot1.1 (another test-level README like this one) improves on
the above taxonomy.)




## about our relationship with ruby versions

the files here compile (`ruby -wc <file>`) without producing any
warnings, using the ruby version that corresponds to the `.ruby-version`
at the root of the ecosystem at this writing (more on this below).

originally we named the containing directory after this ruby version
(`ruby-MRI-2.4.1`), thinking that as new versions of ruby with syntax
changes were released, we would add new fixture trees, one for each
version we were targeting with the according code. (perhaps we would
take this strategy backward for targeting older ruby vesions.)

but then we decided that what is perhaps a better solution is to always
track whatever our "current version" of ruby is, and adapt these fixture
code files and whatever (sob) asset code as necessary to be compliant with
this version.

as it stands, anyway, we use the 'parser' gem's "current version" default
and it itself is emitting the warning about using `2.4.0`-compliant syntax
on our `2.4.1` code, which so far hasn't caused any issues.

(#open [#020.C] tracks the one small issue we had with this (with 'parser'
failing to parse something that's MRI compliant in our current version;
it was quite small..)




## justification for the the now and thoughts for the future on versions

three things about targeting arbitrary (syntactic) versions of ruby:

  - we can just take the cop-out answer and say this is out of our
    current scope, which is reasonable given how young this project is.

  - if we ever attempt such a thing, it would require a significant
    re-architecting of our "hooks" and "tupling" architectures, something
    we are giving thought to currently but it is not an implementation
    priority.

  - if we do reach such a point, it would be interesting/nice if we could
    "splay out" all the language features into many smaller files such that
    you never repeat the same feature twice, except those that have syntax
    changes. but that's getting way ahead of ourselves at the moment!

this is the exact version we used for this:

    ruby 2.4.1p111 (2017-03-22 revision 58053) [x86_64-darwin15]
