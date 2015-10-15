require_relative '../test-support'

module Skylab::Callback::TestSupport::Box

  ::Skylab::Callback::TestSupport[ TS_ = self ]

  include Constants

  extend TestSupport_::Quickie

  Home_ = Home_

  module ModuleMethods

    def memoize_subject & p

      define_method :subject, Home_.memoize( & p )

    end
  end

  module InstanceMethods

    def subject_with_entries * pairs
      bx = Subject_[].new
      pairs.each_slice 2 do | k, x |
        bx.add k, x
      end
      bx
    end

  end

  Subject_ = -> do
    Home_::Box
  end
end
