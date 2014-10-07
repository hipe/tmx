require_relative '../test-support'

module Skylab::Brazen::TestSupport::Entity::Properties_Stack__::Common_Frame__

  ::Skylab::Brazen::TestSupport::Entity::Properties_Stack__[ self ]

  include CONSTANTS

  extend TestSupport_::Quickie

  Brazen_ = Brazen_

  Sandboxer = TestSupport_::Sandbox::Spawner.new

  module CONSTANTS

    Subject_ = -> * a do
      if a.length.zero?
        Brazen_.properties_stack.common_frame
      else
        Brazen_.properties_stack.common_frame.via_arglist a
      end
    end
  end

  Subject_ = Subject_
end
