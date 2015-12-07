require 'skylab/zerk'
require 'skylab/test_support'

module Skylab::Zerk::TestSupport

  class << self

    def [] tcc

      Callback_.test_support::Expect_event[ tcc ]
      tcc.include TS_
    end

    def lib sym
      _libs.public_library sym
    end

    def lib_ sym
      _libs.protected_library sym
    end

    def _libs
      @___libs ||= TestSupport_::Library.new TS_
    end
  end  # >>

  TestSupport_ = ::Skylab::TestSupport
  extend TestSupport_::Quickie

  # ->

    def debug!
      @do_debug = true
    end

    attr_reader :do_debug

    def debug_IO
      TestSupport_.debug_IO
    end

    def call * x_a
      @branch ||= build_branch
      Home_::API.produce_bound_call x_a, @branch
    end

    def build_branch
      branch_class.new build_mock_parent
    end

    def build_mock_parent
      evr = event_receiver_for_expect_event
      Mock_Parent__.new -> i_a, & ev_p do
        evr.maybe_receive_on_channel_event i_a, & ev_p
      end
    end

    def expression_agent_for_expect_event
      Home_.lib_.brazen::API.expression_agent_instance
    end

    Mock_Parent__ = ::Struct.new :handle_event_selectively_via_channel do

      def is_interactive
        false
      end
    end

  # -

  Home_ = ::Skylab::Zerk

  Home_::Autoloader_[ self, ::File.dirname( __FILE__ ) ]

  Callback_ = Home_::Callback_
  MONADIC_EMPTINESS_ = -> _ { NIL_ }
  NIL_ = nil
  TS_ = self
end
