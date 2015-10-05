require_relative '../../../../test-support'

module Skylab::Brazen::TestSupport::Pstack_Cframe

  ::Skylab::Brazen::TestSupport[ self ]

  include Constants

  extend TestSupport_::Quickie

  module Constants

    Subject_ = -> * a do
      if a.length.zero?
        Home_::Property::Stack.common_frame
      else
        Home_::Property::Stack.common_frame.call_via_arglist a
      end
    end
  end

  Home_ = Home_
  Subject_ = Subject_
end
