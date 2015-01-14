require_relative '../test-support'

module Skylab::MetaHell::TestSupport::Parse

  ::Skylab::MetaHell::TestSupport[ self ]

  include Constants

  MetaHell_ = MetaHell_

  extend TestSupport_::Quickie

  LIB_ = ::Object.new
  class << LIB_

    def DSL_DSL
      MetaHell_::DSL_DSL
    end
  end

  Subject_ = -> do
    MetaHell_::Parse
  end

  Constants::LIB_ = LIB_

  Constants::Subject_ = Subject_

end
