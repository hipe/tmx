require_relative '../test-support'

module Skylab::MetaHell::TestSupport::Modul
  (Parent_ = ::Skylab::MetaHell::TestSupport)[ self ] # regret, #ts-002

  module CONSTANTS
    include Parent_::CONSTANTS
    Modul = MetaHell::Modul
  end

end
