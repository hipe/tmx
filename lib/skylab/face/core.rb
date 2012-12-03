require_relative '..'
require 'skylab/meta-hell/core'

module Skylab::Face

  Face = self
  MetaHell = ::Skylab::MetaHell

  extend MetaHell::Autoloader::Autovivifying::Recursive

  module CLI
    # you won't believe this -- during transition there is actually
    # both a module called `Face::CLI` and a class called `Face::Cli` :/
    # This is only necessary during that time.

    extend MetaHell::Autoloader::Autovivifying::Recursive
      # we don't want face/cli.rb to know about our existence, for old
      # libraries that still use it standalone
  end
end
