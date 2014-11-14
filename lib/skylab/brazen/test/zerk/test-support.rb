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

    def initialize ev_p
      @ev_p = ev_p
    end

    def primary_UI_yielder
      :_do_not_use_primary_UI_yielder_here_
    end

    def serr
      :_do_not_use_standard_error_here_
    end

    def sin
      :_do_not_use_standard_in_here_
    end

    def receive_event ev
      @ev_p[ ev ]
      ev.ok
    end
  end
end
