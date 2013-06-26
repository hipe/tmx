require_relative '..'
require 'skylab/headless/core'
require 'skylab/information-tactics/core'
require 'skylab/meta-hell/core'

module Skylab::MyTree

  Headless = ::Skylab::Headless
  InformationTactics = ::Skylab::InformationTactics
  MetaHell = ::Skylab::MetaHell
  MyTree = self

  extend MetaHell::Autoloader::Autovivifying::Recursive

  module API
    extend MetaHell::Autoloader::Autovivifying::Recursive
    module Actions
      MetaHell::Boxxy[ self ]
    end
  end
end
