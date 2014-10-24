# an introduction to headless CLI

• you will note that we say "headless" in the title here but not elsewhere.
  it would generally be redundant to describe everything here as "headless"
  because that is always the library we are under. we include the term here
  because the title "an introduction to CLI" would be misleading.

• "headless CLI" is an oxymoron to be sure. this is an issue we hope to
  address in the future.

• you will note that this document does not have "narrative" in the  title.
  that is because this text does not narrate an accompanying code node.
  that, in turn, is because there is no "CLI" code node proper: CLI the
  node in fact gets auto-vivified as a module the first time it is accessed
  only because there is a corresponding directory with that name. nothing
  here expressly adds anything to the CLI node "itself" except modules that
  define themselves into it. this is by design, to encourage modularity and
  indepence of the sub-node. we want this to act as a library more than a
  framework.  :[#126]
