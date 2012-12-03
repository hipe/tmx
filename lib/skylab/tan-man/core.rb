require_relative '..' # skylab.rb
require 'skylab/code-molester/core'
require 'skylab/treetop-tools/core'


module Skylab
  module TanMan
    Autoloader   = ::Skylab::Autoloader
    Bleeding     = ::Skylab::Porcelain::Bleeding
    CodeMolester = ::Skylab::CodeMolester
    Face         = ::Skylab::Face
    Headless     = ::Skylab::Headless
    Inflection   = ::Skylab::Autoloader::Inflection
    MetaHell     = ::Skylab::MetaHell
    Porcelain    = ::Skylab::Porcelain
    PubSub       = ::Skylab::PubSub
    TanMan       = self #sl-107 (pattern)
    TreetopTools = ::Skylab::TreetopTools

    extend MetaHell::Autoloader::Autovivifying::Recursive
  end


  module TanMan::Core
    extend MetaHell::Autoloader::Autovivifying::Recursive
  end
end
