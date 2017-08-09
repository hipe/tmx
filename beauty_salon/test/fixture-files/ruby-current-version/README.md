# readme

## caveat for each of these files

each of these files exists to add coverage to "crazy town" for
grammatical symbols that need to be covered.

it should be safe to add components to any such file, but don't
remove components from it.




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
on our `2.4.1` code, which so far hasn't caused any issues. (near #open [#020])




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
