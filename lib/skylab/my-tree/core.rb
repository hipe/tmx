require_relative '..'
require 'skylab/headless/core'
require 'skylab/information-tactics/core'
require 'skylab/meta-hell/core'

module Skylab::MyTree

  Headless = ::Skylab::Headless
  InformationTactics = ::Skylab::InformationTactics
  MetaHell = ::Skylab::MetaHell
  MyTree = self

  MetaHell::MAARS[ self ]

  module API

    MetaHell::MAARS[ self ]

    module Actions
      MetaHell::Boxxy[ self ]
    end
  end
end
