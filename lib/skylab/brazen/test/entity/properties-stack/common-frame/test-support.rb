require_relative '../test-support'

module Skylab::Brazen::TestSupport::Entity::Properties_Stack::Common_Frame

  ::Skylab::Brazen::TestSupport::Entity::Properties_Stack[ self ]

  include Constants

  extend TestSupport_::Quickie

  Brazen_ = Brazen_

  module Constants

    Subject_ = -> * a do
      if a.length.zero?
        Brazen_.properties_stack.common_frame
      else
        Brazen_.properties_stack.common_frame.call_via_arglist a
      end
    end
  end

  Subject_ = Subject_
end
