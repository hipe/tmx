require 'skylab/zerk'
require 'skylab/test_support'

module Skylab::Zerk::TestSupport

  class << self

    def [] tcc
      tcc.send :define_singleton_method, :use, Use_method___
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
  Lazy_ = Callback_::Lazy

  # -
    Use_method___ = -> sym do
      TS_.lib_( sym )[ self ]
    end
  # -

  # -

    def debug!
      @do_debug = true
    end

    attr_reader :do_debug

    def debug_IO
      TestSupport_.debug_IO
    end
  # -

  # -- the test library node called "API"

  API = -> tcc do

    TestSupport_::Memoization_and_subject_sharing[ tcc ]
    Callback_.test_support::Expect_event[ tcc ]
    tcc.include API_Instance_Methods___ ; nil
  end

  module API_Instance_Methods___

    def call_plus_ * args

      guy = build_top_
      @result = guy.call_via_argument_array_ args
      @_top = guy.freeze
      NIL_
    end

    def call_ * args

      _guy = build_top_
      @result = _guy.call_via_argument_array_ args

      NIL_
    end

    def build_top_

      _cls = top_ACS_class_

      _oes_p = ___handle_event_selectively

      _cls.new( & _oes_p )
    end

    def ___handle_event_selectively

      _manually = oes_p_
      _manually || event_log.handle_event_selectively
    end

    attr_reader :oes_p_

    def expect_result_for_failure_
      state_.result.should match_result_for_failure_
    end

    def match_result_for_failure_
      eql Home_::UNABLE_
    end

    def expect_result_for_success_
      state_.result.should eql ACHIEVED_
    end

    define_method :expression_agent_for_expect_event, ( Lazy_.call do
      Home_.lib_.brazen::API.expression_agent_instance
    end )

    # --

    def flush_state_plus_

      o = flush_state_
      State_After_Invocation_Plus___[
        remove_instance_variable( :@_top ),
        o.result,
        o.emission_array,
      ]
    end

    State_After_Invocation_Plus___ = ::Struct.new(
      :top,
      :result,
      :emission_array,
    )

    def flush_state_

      _x = remove_instance_variable :@result

      _a = remove_instance_variable( :@event_log ).flush_to_array

      State_After_Invocation___.new _x, _a
    end

    State_After_Invocation___ = ::Struct.new(
      :result,
      :emission_array,
    )
  end

  # mocks

  fn_rx = %r(\A[^/])

  fnm = nil
  File_Name_Model_ = -> arg_st, & oes_p_p do

    if arg_st.no_unparsed_exists
      # experimental to use #[#ac-002]Detail-one
      Callback_::KNOWN_UNKNOWN
    else
      fnm[ arg_st, & oes_p_p ]
    end
  end

  fnm = -> arg_st, & oes_p_p do

    x = arg_st.gets_one
    if x.length.zero?
      self._K
    elsif fn_rx =~ x
      Callback_::Known_Known[ x ]
    else
      _oes_p = oes_p_p[ nil ]
      _oes_p.call :error, :expression, :invalid_value do | y |
        y << "paths can't be absolute - #{ ick x }"
      end
      UNABLE_
    end
  end

  # -- busi speci

  module Unmarshal_and_Call_and_Marshal_

    def initialize & oes_p
      @oes_p_ = oes_p
    end

    def call_via_argument_array_ args
      Home_.call args, self
    end

    def unmarshal_from_ st
      Home_.unmarshal st, self
    end

    def persist_into_ * x_a
      Home_.persist x_a, self
    end

    def event_handler_for _
      @oes_p_
    end

    def component_event_model
      :hot
    end
  end

  EMPTY_JSON_LINES_ = [ "{}\n" ]

  # -- exp

  Future_expect_nothing_ = Lazy_.call do
    -> * i_a do
      fail "unexpected: #{ i_a.inspect }"
    end
  end

  class Future_Expect_ < ::Proc

    class << self

      def _call * expected_sym_a

        p = nil

        o = new do | * sym_a, & ev_p |
          p[ * sym_a, & ev_p ]
        end

        Callback_.test_support::Future_Expect[ o.singleton_class ]

        o.add_future_expect expected_sym_a

        p = o.fut_p

        o
      end

      alias_method :[], :_call

      alias_method :call, :_call
    end  # >>

    def do_debug
      false
    end

    def done_
      future_is_now
    end
  end

  Home_::Autoloader_[ self, ::File.dirname( __FILE__ ) ]

  ACHIEVED_ = true
  EMPTY_A_ = []
  EMPTY_S_ = "".freeze
  MONADIC_EMPTINESS_ = -> _ { NIL_ }
  NEWLINE_ = "\n"
  NIL_ = nil
  TS_ = self
  UNABLE_ = false
end
