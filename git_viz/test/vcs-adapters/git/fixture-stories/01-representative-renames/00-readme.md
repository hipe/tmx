# readme.

## what it means to rebuild a story and how to do it

### introduction

this is the build process for this mock repository. it needs to be rebuilt
only when its "story" changes, e.g during development. otherwise, the
necessary assets (and nothing else) are tracked here and/or are already
part of the distribution; i.e. re-building the story not normally necessary.



### what is a "story" in this context?

"story" is our chosen jargon term for some fake command and fake files
that go together. real commands are "recorded" here, when you rebuild
the story. then when tests are run, what you recorded here is "played back".
more at [#007].





### requirements to rebuild the story

  + bash of some particular version
    + some stories need zsh of some particular version (for HEREDOCS)
  + git of some particular version
  + ruby of the same version of the host application




### rebuilding the story

from the shell, from any directory, run the scripts in the order
suggested by their name. each script assumes the previous script's
successful outcome so don't bother trying to get a later one to work
if a previous one fails.

some scripts are in bash and some are in ruby, which is not relevant to
us here.

for example, from the directory that contains this readme file:

  ./01-build-the-repo

  ./02-build-the-manifest

  ./03-normalize-the-manifest

  ./04-cleanup

when that is finished, your "manifest" files should be changed to
reflect what happened in the story. if there are no changes, perhaps the
story didn't change.




## about this story

this first story focuses on renames: a "representative sample" of them
to try and capture edge cases near [#019] for [#gi-001], which currently
doesn't have coverage.

we don't care about detecting edits to content here so we don't do any.
