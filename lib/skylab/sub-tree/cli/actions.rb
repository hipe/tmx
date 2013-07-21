module Skylab::SubTree

  module CLI::Actions

    MetaHell::Boxxy[ self ]  # BOXXY

  end

  SubTree::Services::Set || nil  # kinda janky here but whatever:
  # one or more children actions require arrays to respond to the `to_set`
  # message, so we use this to pull it in, in keeping with convention of
  # pulling all dependencies in (lazily when possible) with the same
  # centralized services pattern.

end
