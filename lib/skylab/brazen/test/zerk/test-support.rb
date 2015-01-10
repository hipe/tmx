require_relative '../test-support'

module Skylab::Brazen::TestSupport::Zerk

  ::Skylab::Brazen::TestSupport[ self ]

  module Constants
    Zerk_ = Brazen_::Zerk
  end

  include Constants

  Brazen_ = Brazen_
  Zerk_ = Zerk_

  module InstanceMethods

    Constants::TestLib_::Expect_event[ self ]

    def call * x_a
      @branch ||= build_branch
      Zerk_::API.produce_bound_call x_a, @branch
    end

    def build_branch
      branch_class.new build_mock_parent
    end

    def build_mock_parent
      evr = event_receiver_for_expect_event
      Mock_Parent__.new -> *, & ev_p do
        evr.receive_ev ev_p[]
      end
    end
  end

  Mock_Parent__ = ::Struct.new :handle_event_selectively_via_channel do

    def is_interactive
      false
    end
  end
end
