require_relative '../test-support'

module Skylab::MetaHell::TestSupport::Formal

  ::Skylab::MetaHell::TestSupport[ Formal_TS_ = self ]

  include Constants

  MetaHell_ = MetaHell_ # bc of metahell

  extend TestSupport_::Quickie

  class << self

    define_method :next_id, -> do
      d = 0
      -> do
        d += 1
      end
    end.call
  end

  module Constants
    Formal_TS_ = Formal_TS_
  end

  module ModuleMethods
    include Constants
    def subject func
      memoize_ :subject, & func
      nil
    end
  end
end
