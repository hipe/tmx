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

    Brazen_::TestSupport::Expect_Event[ self ]

    def call * x_a
      @branch ||= build_branch
      Zerk_::API.produce_bound_call x_a, @branch
    end

    def build_branch
      branch_class.new build_mock_parent
    end

    def build_mock_parent
      @evr = event_receiver
      Mock_Parent__.new method( :recv_event )
    end

    def recv_event ev
      event_receiver.receive_event ev
    end
  end

  class Mock_Parent__

    def initialize recv_p
      @handle_event_selectively_via_channel = -> _, & ev_p do
        recv_p[ ev_p[] ]
      end
    end

    attr_reader :handle_event_selectively_via_channel

    def is_interactive
      false
    end
  end
end
