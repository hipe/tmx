require 'skylab/zerk'
require 'skylab/test_support'

module Skylab::Zerk::TestSupport

  class << self

    def [] tcc

      TestSupport_::Memoization_and_subject_sharing[ tcc ]
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

  Home_ = ::Skylab::Zerk
  Callback_ = Home_::Callback_

  # ->

    def debug!
      @do_debug = true
    end

    attr_reader :do_debug

    def debug_IO
      TestSupport_.debug_IO
    end

    def call_ * args

      _guy = build_top_
      @result = _guy.call_via_argument_array_ args
      NIL_
    end

    def build_top_

      _cls = top_ACS_class_

      _oes_p = event_log.handle_event_selectively

      _cls.new( & _oes_p )
    end

    def expect_result_for_failure_
      state_.result.should match_result_for_failure_
    end

    def match_result_for_failure_
      eql Home_::UNABLE_
    end

    define_method :expression_agent_for_expect_event, ( Callback_::Lazy.call do
      Home_.lib_.brazen::API.expression_agent_instance
    end )

    # -- will certainly go up to expev in some form. ..

    def flush_state_

      _a = remove_instance_variable( :@event_log ).flush_to_array

      _x = remove_instance_variable :@result

      State_After_Invocation___.new _x, _a
    end

    State_After_Invocation___ = ::Struct.new :result, :emission_array

    # -

    if false

    def call * x_a
      @branch ||= build_branch
      Home_::API.produce_bound_call x_a, @branch
    end

    def build_branch
      branch_class.new build_mock_parent
    end

    def build_mock_parent

      oes_p = event_log.handle_event_selectively

      Mock_Parent__.new -> x_a, & ev_p do

        oes_p[ * x_a, & ev_p ]
      end
    end

    def expect_not_OK_event_ sym, msg=nil

      em = expect_not_OK_event nil, msg
      em.cached_event_value.to_event.terminal_channel_symbol.should eql sym
      em
    end

    def expect_OK_event_ sym, msg

      em = expect_OK_event nil, msg
      em.cached_event_value.to_event.terminal_channel_symbol.should eql sym
      em
    end

    def expression_agent_for_expect_event
      Home_.lib_.brazen::API.expression_agent_instance
    end

    Mock_Parent__ = ::Struct.new :handle_event_selectively_via_channel do

      def is_interactive
        false
      end
    end
    end

  # -

  Call_ = -> args, acs do
    Home_.call args, acs
  end

  Unmarshal_ = -> x, y do
    Home_.unmarshal x, y
  end

  Persist_ = -> x, y do
    Home_.persist x, y
  end

  Home_::Autoloader_[ self, ::File.dirname( __FILE__ ) ]

  EMPTY_A_ = []
  MONADIC_EMPTINESS_ = -> _ { NIL_ }
  NIL_ = nil
  TS_ = self
end
