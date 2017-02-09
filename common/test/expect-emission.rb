module Skylab::Common::TestSupport

  module Expect_Emission  # some notes in [#065]

    # per name conventions, all method *and ivar* names with neither leading
    # nor trailing underscores are part of the [sub-]subject's public API.

    # in the subject module those methods that are not part of the public
    # API will use the reserved name-piece "expev" in the name to avoid
    # unintentional collision with names in other [event] libraries.

    class << self

      def [] tcc, x_a=nil

        tcc.include Test_Context_Instance_Methods

        if x_a && x_a.length.nonzero?
          x_a.each_slice 2 do | sym, x |
            tcc.send :instance_exec, x, & OPTS___.fetch( sym )
          end
        end

        NIL_
      end
    end  # >>

    IGNORE_METHOD__ = :ignore_for_expect_emission

    OPTS___ = {

      ignore: -> sym do

        h = { sym => true }

        define_method IGNORE_METHOD__ do h end ; nil
      end,

      ignore_these: -> a do

        h = ::Hash[ a.map { | sym | [ sym, true ] } ]

        define_method IGNORE_METHOD__ do h end ; nil
      end,
    }

    IGNORE_THESE_EVENTS_METHOD = -> * terminal_channel_sym_a do

      h = ::Hash[ terminal_channel_sym_a.map { | sym | [ sym, true ] } ]

      define_method IGNORE_METHOD__ do
        h
      end
    end

    # -- oldschool retro-fitting (see [#]note-C)

      module Test_Context_Instance_Methods

        def call_API * x_a, & x_p
          call_API_via_iambic x_a, & x_p
        end

        def call_API_via_iambic x_a, & oes_p
          if ! block_given?
            oes_p = event_log.handle_event_selectively
          end
          @result = subject_API.call( * x_a, & oes_p )
          NIL_
        end

        def expect_one_event_and_neutral_result * x_a, & p
          em = _next_actual_expev_emission do | em_ |
            em_.should _match_expev_em_via_TCS( * x_a, & p )
          end
          if em
            _expect_no_next_actual_expev_emission
            # (note we don't let a failure above mess up the rest:)
            em
          end
        end

        def expect_one_event * x_a, & p
          em = _next_actual_expev_emission do | em_ |
            em_.should _match_expev_em_via_TCS( * x_a, & p )
          end
          if em
            _expect_no_next_actual_expev_emission
            em
          end
        end

        def expect_not_OK_event * x_a, & p
          _next_actual_expev_emission do | em |
            em.should _match_expev_em_via_3( false, * x_a, & p )
          end
        end

        def expect_neutral_event * x_a, & p
          _next_actual_expev_emission do | em |
            em.should _match_expev_em_via_3( nil, * x_a, & p )
          end
        end

        def expect_OK_event * x_a, & p
          _next_actual_expev_emission do | em |
            em.should _match_expev_em_via_3( true, * x_a, & p )
          end
        end

        def expect_event * x_a, & p
          _next_actual_expev_emission do | em |
            em.should _match_expev_em_via_TCS_and_message( * x_a, & p )
          end
        end

        def expect_no_events
          _expect_no_next_actual_expev_emission
        end

        def expect_no_more_events
          _expect_no_next_actual_expev_emission
        end

        def flush_to_event_stream
          # (kept for continuity with a possible future)
        end

        # ~ emission..

        def expect_emission * sym_a, & exp_y_p

          # (written to accomodate the "expression" shape of event)
          # (experimentally now a hybrid of oldschool/newschool

          if instance_variable_defined? :@event_log
            __expect_emission_oldschool exp_y_p, sym_a
          else
            _em = only_emission
            _do_expect_emission _em, exp_y_p, sym_a
          end
        end

        def __expect_emission_oldschool exp_y_p, sym_a

          _next_actual_expev_emission do |em|

            _do_expect_emission em, exp_y_p, sym_a
          end
        end

        def _do_expect_emission em, p, sym_a

          if em.channel_symbol_array == sym_a
            if p
              p[ em._event_or_lines_ ]
            end
          else
            em.channel_symbol_array.should eql sym_a
          end
        end

        # ~ expectations along the different qualities of events

        def black_and_white ev
          black_and_white_lines( ev ).join NEWLINE_
        end

        def black_and_white_lines ev
          _expag = _expev_upper_level_expression_agent
          ev.express_into_under [], _expag
        end

        # ~ support and resolution

        def expect_failed_by * x_a, & x_p
          em = _next_actual_expev_emission do | em_ |
            if 1 == x_a.length
              x_a.push nil
            end
            em_.should _match_expev_em_via_3( false, * x_a, & x_p )
          end
          expect_fail
          em
        end

        def expect_fail
          __expev_expect_failed_result
          _expect_no_next_actual_expev_emission
        end

        def expect_neutralled
          expect_neutral_result
          _expect_no_next_actual_expev_emission
        end

        def expect_succeed
          expect_succeeded_result
          _expect_no_next_actual_expev_emission
        end

        def __expev_expect_failed_result
          if false != @result
            _expev_fail Say_unexpected_result__[ @result, false ]
          end
        end

        def expect_neutral_result
          if nil != @result
            _expev_fail Say_unexpected_result__[ @result, nil ]
          end
        end

        def expect_succeeded_result
          if true != @result
            _expev_fail Say_unexpected_result__[ @result, true ]
          end
        end

        def expect_freeform_event sym, & ev_p  # this is a retrofit -
          # a new method to make old code work in the old way [cm]
          _next_actual_expev_emission do | em |
            em.should _match_expev_em_via_TCS( sym, & ev_p )
          end
        end
      end

    # --

    Common_ = Home_  # b.c we keep forgetting ..
    Lazy_ = Home_::Lazy_

    module Test_Context_Instance_Methods

      # -- flush state

      def flush_event_log_and_result_to_state x

        _a = remove_instance_variable( :@event_log ).flush_to_array
        State.new x, _a
      end

      # -- log-based event testing

      def event_log
        @event_log ||= build_event_log  # ivar name is #public-API
      end

      def build_event_log

        log = Log.for self

        h = send IGNORE_METHOD__
        if h
          log.set_hash_of_terminal_channels_to_ignore h
        end

        log
      end

      define_method IGNORE_METHOD__ do
        NIL_
      end
    end  # will reopen

    # ==

    debugging_expression_agent_for = nil

    Debugging_listener_for___ = -> tc do

      # a series of tomstones. this replaces what is in #tombstone-C

      io = tc.debug_IO

      _expag = debugging_expression_agent_for[ tc ]

      o = Zerk_for_test_support_[]::Expresser.via_expression_agent _expag
      o.downstream_stream = io
      o = o.finish

      -> em do
        chan = em.channel_symbol_array
        io.write "#{ chan.inspect } "  # SPACE_
        if em.is_expression
          o.handle chan do |y|
            calculate y, & em.expression_proc
          end
        else
          _ev = em.cached_event_value  # assume not ignored, because you're here
          o.handle chan do
            _ev
          end
        end
        UNRELIABLE_
      end
    end

    debugging_expression_agent_for = -> tc do
      if tc.respond_to? DEBUGGING_EXPEV_METHOD__
        tc.send DEBUGGING_EXPEV_METHOD__
      elsif tc.respond_to? BLACK_AND_WHITE_EXPEV_METHOD__
        tc.send BLACK_AND_WHITE_EXPEV_METHOD__
      elsif tc.respond_to? EXPEV_METHOD__
        tc.send EXPEV_METHOD__
      else
        Black_and_white_expression_agent__[]
      end
    end

    # ==

    module Test_Context_Instance_Methods  # re-opened

      # -- newschool support for the oldschool ways

      # ~ gets'ing (or expecting not to gets) each next emission

      def _next_actual_expev_emission

        em = _gets_expev_emission
        if em
          yield em
          em  # guaranteed
        else
          _expev_fail ___say_expected_another_expev_event_had_none
        end
      end

      def ___say_expected_another_expev_event_had_none
        "expected another event, had none"
      end

      def _expect_no_next_actual_expev_emission

        em = _gets_expev_emission
        if em
          _expev_fail ___say_expect_no_more_expev_events_had_emission em
        else
          ACHIEVED_  # not sure
        end
      end

      def _expev_fail s
        fail s
      end

      def ___say_expect_no_more_expev_events_had_emission em
        "expected no more events, had #{ _expect_event_description em }"
      end

      def _gets_expev_emission  # a compound assumption.. (#note-B)
        @event_log.gets
      end

      # ~ produce matchers to link old to new

      def _match_expev_em_via_TCS terminal_channel_symbol, & ev_p

        _expev_matcher_by do

          terminal_channel_symbol_of terminal_channel_symbol

          if ev_p
            traditional_user_proc_of ev_p
          end
        end
      end

      def _match_expev_em_via_TCS_and_message sym=nil, msg_x=nil, & ev_p

        _expev_matcher_by do

          if sym
            terminal_channel_symbol_of sym
          end

          if msg_x
            mixed_message_matcher msg_x
          end

          if ev_p
            traditional_user_proc_of ev_p
          end
        end
      end

      def _match_expev_em_via_3 ok_trilean, sym=nil, msg_x=nil, & ev_p

        _expev_matcher_by do

          trilean ok_trilean

          if sym
            terminal_channel_symbol_of sym
          end

          if msg_x
            mixed_message_matcher msg_x
          end

          if ev_p
            traditional_user_proc_of ev_p
          end
        end
      end

      def _expect_event_description em
        em.channel_symbol_array.inspect
      end

      # -- out-of-scope but convenient

      def be_common_result_for_failure
        eql false
      end

      # -- the newschool ways (matcher-based) (frontiered by [ze] for now..)

      def fails
        _state = state_for_expect_emission
        expect_failure_value _state.result
      end

      def expect_failure_value x
        x == false || fail( "did not fail - expected false, had #{ String_via_mixed__[ x ] }" )
      end

      def result_is_nothing
        state = state_for_expect_emission
        state.result.nil? || fail( "needed nil had #{ String_via_mixed__[ state.result ] }" )
      end

      def expect_no_emissions
        a = emission_array
        if a
          a.length.zero? || fail
        end
      end

      def emission_count
        emission_array.length
      end

      def only_emission

        a = emission_array
        em = a.fetch 0
        if 1 == a.length
          em
        else
          a.length.should eql 1
        end
      end

      def first_emission
        emission_array.first
      end

      def second_emission
        emission_array.fetch 1
      end

      def last_emission
        emission_array.last
      end

      def emission_array
        state_for_expect_emission.emission_array
      end

      def be_emission_beginning_with * x_a, & x_p

        _expev_matcher_by do

          channel_head_of x_a

          if x_p
            alternate_user_proc_of x_p
          end
        end
      end

      def be_emission_ending_with * x_a, & x_p

        _expev_matcher_by do

          channel_tail_of x_a

          if x_p
            alternate_user_proc_of x_p
          end
        end
      end

      def be_emission * x_a, & x_p
        be_emission_via_array x_a, & x_p
      end

      def be_emission_via_array x_a, & x_p

        _expev_matcher_by do

          full_channel_of x_a

          if x_p
            alternate_user_proc_of x_p
          end
        end
      end

      def _expev_matcher_by & def_p

        Expectation__.new do
          instance_exec( & def_p )
        end.to_matcher_bound_to self
      end

      # -- internal support

      def _expev_upper_level_expression_agent
        if respond_to? BLACK_AND_WHITE_EXPEV_METHOD__
          send BLACK_AND_WHITE_EXPEV_METHOD__
        else
          black_and_white_expression_agent_for_expect_emission_normally
        end
      end

      def black_and_white_expression_agent_for_expect_emission_normally
        Black_and_white_expression_agent__[]
      end

      def _expev_lower_level_expression_agent
        if respond_to? MY_EXPEV_METHOD__
          send MY_EXPEV_METHOD__
        else
          expression_agent_for_expect_emission_normally
        end
      end

      def expression_agent_for_expect_emission_normally
        Codifying_expresion_agent__[]
      end
    end

    # ==

    class Emission_Matcher___

      def initialize expectation, tc
        @_expectation = expectation
        @_test_context = tc
      end

      def matches? em

        @_emission = em  # :/
        @_failures = nil

        exp = @_expectation
        if exp.has_trilean
          ___check_trilean
        end

        m = exp.channel_method_name
        if m
          send m
        end

        # we conditionally skip the below checks because [#]note-A

        m = exp.message_method_name
        if m && ! @_failures
          send m
        end

        m = exp.user_proc_method_name
        if m && ! @_failures
          send m
        end

        if @_failures
          __when_failed
        else
          @_emission
        end
      end

      def ___check_trilean

        if @_expectation.trilean_value != @_emission._trilean_

          _add_failure_by do

            _exp_x = @_expectation.trilean_value
            _act_x = @_emission._trilean_

            "expected event's `ok` value to be #{ Say_trilean__[ _exp_x ] },#{
              } was #{ Say_not_trilean__[ _act_x ] }"
          end
        end
        NIL_
      end

      def check_channel_tail

        act = @_emission.channel_symbol_array
        exp = @_expectation.channel_tail

        Require_basic__[]

        act_d, exp_d =
         Basic_::List.lowest_indexes_of_tail_anchored_common_element act, exp

        if ! exp || exp_d.nonzero?
          _add_failure_by do
            ___say_channel_tail act_d, exp_d, act, exp
          end
        end
        NIL_
      end

      def ___say_channel_tail act_d, exp_d, act, exp

        "needed last #{ exp.length } component(s) to be #{
          }#{ exp.inspect } in #{ act.inspect }"
      end

      def check_full_channel

        # if the actual channel is deeper than the expected channel,
        # but the expect channel matches the head-anchored slice, it's still
        # a match (FOR NOW)..

        _check_channel_head @_expectation.full_channel
      end

      def check_channel_head
        _check_channel_head @_expectation.channel_head
      end

      def _check_channel_head exp

        act = @_emission.channel_symbol_array

        Require_basic__[]
        good_d = Basic_::List.index_of_deepest_common_element act, exp

        bad_d = if good_d
          good_d + 1
        else
          0
        end

        if exp.length != bad_d

          _add_failure_by do
            ___say_detailed_explanation_about_channel_mismatch bad_d, act, exp
          end
        end
        NIL_
      end

      Require_basic__ = Lazy_.call do
        Basic_ = Home_.lib_.basic
        NIL_
      end

      def ___say_detailed_explanation_about_channel_mismatch bad_d, act, exp

        _ord = Basic_::Number::EN.num2ord bad_d + 1

        _had_x = String_via_mixed__[ act[ bad_d ] ]  # any
        _need_x = String_via_mixed__[ exp[ bad_d ] ]  # any

        _had = act.inspect

        "had #{ _had_x }, needed #{ _need_x } for the #{ _ord } component of #{
          }#{ _had }"
      end

      def check_terminal_channel_symbol

        if @_expectation.terminal_channel_symbol !=
            @_emission.channel_symbol_array.last

          _add_failure_by do

            _exp_x = @_expectation.terminal_channel_symbol
            _act_x = @_emission.channel_symbol_array.last

            "expected `#{ _exp_x }` event, had `#{ _act_x }`"
          end
        end
        NIL_
      end

      # for the next two, we don't leverage built-in predicates for same
      # so we control how the failure is represented (i.e where it goes)

      # also, on failure the string may be rendered twice (and on success
      # it is never stored.)

      def check_message_string_against_string

        if @_expectation.message_string != _actual_string_normalized_by_user

          _add_message_failure_by do | act_s |

            "expected #{ @_expectation.message_string.inspect }, #{
              }had #{ act_s.inspect }"
          end
        end
        NIL_
      end

      def check_message_string_against_regexp

        if @_expectation.message_regexp !~ _actual_string_normalized_by_user

          _add_message_failure_by do | act_s |

            "did not match #{ @_expectation.message_regexp.inspect } - #{
              }#{ act_s.inspect }"
          end
        end
        NIL_
      end

      def check_user_proc_alternately

        p = @_expectation.alternate_user_proc

        em = @_emission

        if em.is_expression
          _expag = @_test_context._expev_lower_level_expression_agent
          _x = _expag.calculate [], & em.expression_proc
        else
          _x = em.cached_event_value
        end

        p[ _x ]
        UNRELIABLE_
      end

      def check_user_proc_traditionally

        @_expectation.traditional_user_proc[ @_emission.cached_event_value ]
        # result is disregarded. you only ever always get the emission back.

        UNRELIABLE_
      end

      # --

      def _add_message_failure_by

        _add_failure_by do
          yield _actual_string_normalized_by_user
        end
      end

      def _actual_string_normalized_by_user

        _expag = @_test_context._expev_lower_level_expression_agent

        _lines = @_emission._express_into_under_ [], _expag

        _lines.join NEWLINE_
      end

      def _add_failure_by & msg_p
        ( @_failures ||= [] ).push msg_p
      end

      def __when_failed  # #c.p

        if @_test_context.respond_to? :quickie_fail_with_message_by
          _p = method :failure_message_for_should
          @_test_context.quickie_fail_with_message_by( & _p )
        else
          UNABLE_
        end
      end

      def failure_message_for_should  # #c.p

        _s_a = @_failures.reduce [] do | m, p |
          m << p[]
        end

        _s_a.join NEWLINE_
      end
    end

    # ==

    class Expectation__

      def initialize & def_p
        # (hi.)
        instance_exec( & def_p )
      end

      def trilean x
        @has_trilean = true
        @trilean_value = x ; nil
      end

      def terminal_channel_symbol_of sym
        @channel_method_name = :check_terminal_channel_symbol
        @terminal_channel_symbol = sym ; nil
      end

      def channel_head_of x_a
        @channel_method_name = :check_channel_head
        @channel_head = x_a ; nil
      end

      def channel_tail_of x_a
        @channel_method_name = :check_channel_tail
        @channel_tail = x_a ; nil
      end

      def full_channel_of x_a
        @channel_method_name = :check_full_channel
        @full_channel = x_a ; nil
      end

      def mixed_message_matcher msg_x
        if msg_x.respond_to? :ascii_only?
          @message_method_name = :check_message_string_against_string
          @message_string = msg_x
        else
          @message_method_name = :check_message_string_against_regexp
          @message_regexp = msg_x
        end
        NIL_
      end

      def traditional_user_proc_of p

        @traditional_user_proc = p
        @user_proc_method_name = :check_user_proc_traditionally ; nil
      end

      def alternate_user_proc_of p
        @alternate_user_proc = p
        @user_proc_method_name = :check_user_proc_alternately ; nil
      end

      # --

      def to_matcher_bound_to test_context
        Emission_Matcher___.new self, test_context
      end

      attr_reader(
        :has_trilean,
        :trilean_value,
        # --
        :channel_method_name,
        :terminal_channel_symbol,
        :channel_head,
        :channel_tail,
        :full_channel,
        # --
        :message_method_name,
        :message_string,
        :message_regexp,
        # --
        :user_proc_method_name,
        :traditional_user_proc,
        :alternate_user_proc,
      )
    end

    # ==

    class Log  # exactly #note-5 (see).

      class << self

        def for test_context
          el = new
          if test_context.do_debug
            el.set_auxiliary_listener_by( & Debugging_listener_for___[ test_context ] )
          end
          el
        end
      end  # >>

      def initialize
        @_options = nil
        @_option_time_write = :__first_option_time_write
        @_record_time_read = :__first_record_time_read
        @_read_time_read = :__first_read_time_read
        @_state = :option_time
      end

      # -- read-time

      def gets
        send( @_gets ||= :__first_gets_call )
      end

      def __first_gets_call
        _em_a = release_to_mutable_array
        @__stream = Common_::Stream.via_nonsparse_array _em_a
        @_gets = :__subsequent_gets_call
        _close
        send @_gets
      end

      def __subsequent_gets_call
        @__stream.gets
      end

      def flush_to_scanner
        send @_read_time_read, :__close_as_scanner
      end

      def flush_to_array
        send @_read_time_read, :__close_as_array
      end

      def __first_read_time_read m
        send m
      end

      def __close_as_scanner
        em_a = release_to_mutable_array
        _close
        Common_::Scanner.via_array em_a
      end

      def __close_as_array
        em_a = release_to_mutable_array
        _close
        em_a.freeze
      end

      def release_to_mutable_array  # [dt]

        if :option_time == @_state  # #note-6 - kept simple for now..
          _transition_to_record_time
        end

        remove_instance_variable( :@_record_time ).mutable_array
      end

      def _close
        @_record_time_read = :_method_no_longer_available
        @_read_time_read = :_method_no_longer_available
        @_state = :closed
        freeze
      end

      # -- record-time

      def handle_event_selectively
        send @_record_time_read, :listener
      end

      def shave num  # hacky fun - pop off the last N items with assertion

        em_a = send @_record_time_read, :mutable_array
        em_a.length < num && fail
        r = -num .. -1
        em_a_ = em_a[ r ]
        em_a[ r ] = EMPTY_A_
        em_a_
      end

      def current_emission_count
        send( @_record_time_read, :mutable_array ).length
      end

      def __first_record_time_read k
        _transition_to_record_time
        send @_record_time_read, k
      end

      def _transition_to_record_time

        a = []

        handler = Handler_via_options___[ a, remove_instance_variable( :@_options ) ]

        @_record_time = RecordTime___.new(
          -> * i_a, & ev_p do
            handler[ i_a, & ev_p ]
          end,
          a,
        )

        @_option_time_write = :_method_no_longer_available
        @_record_time_read = :__subsequent_record_time_read
        @_state = :record_time
      end

      def __subsequent_record_time_read k
        @_record_time[ k ]
      end

      # -- configure-time

      def set_auxiliary_listener_by & aux_chan_p
        send @_option_time_write, :aux_handler, aux_chan_p
        NIL
      end

      def set_hash_of_terminal_channels_to_ignore h
        send @_option_time_write, :ignore_term_chan_hash, h
        NIL
      end

      def __first_option_time_write k, x
        @_options = Options___.new
        @_option_time_write = :__subsequent_option_time_write
        send @_option_time_write, k, x
        NIL
      end

      def __subsequent_option_time_write k, x
        @_options[ k ] = x ; nil
      end

      # -- support

      def _method_no_longer_available( * )

        loc, loc_ = caller_locations 1, 2
        _path = ::File.basename loc_.path

        raise MethodNotAvailableFromCurrentState,
          "method `#{ loc.base_label }` is no longer available because #{
            }event log has moved to '#{ @_state }' state (called from #{
              }#{ _path }:#{ loc_.lineno }))"
      end
    end

    MethodNotAvailableFromCurrentState = ::Class.new ::RuntimeError

    # ==

    Options___ = ::Struct.new :aux_handler, :ignore_term_chan_hash

    RecordTime___ = ::Struct.new(
      :listener,
      :mutable_array,
    )

    # ==

    module Handler_via_options___ ; class << self

      # see #note-7 "listener vs. handler"
      #
      # most of subject is concerned with the case of when debugging is
      # on and certain channels are being ignored: for each emission that
      # occurs on an ignored channel we still express some information to
      # the debugging handler (although the emission is not recorded nor the
      # emission payload proc memoized).

      def [] em_a, opts
        if opts
          __handler_when_opts em_a, opts
        else
          _handler_that_records em_a
        end
      end

      def __handler_when_opts em_a, opts

        aux_chan_p = opts.aux_handler
        ignore_h = opts.ignore_term_chan_hash

        if aux_chan_p
          mux_p = __handler_when_mux aux_chan_p, _handler_that_records( em_a )
        end

        if ignore_h

          if aux_chan_p
            when_ignored = ___proc_for_when_ignored_under_mux aux_chan_p
            when_not_ignored = mux_p
          else
            when_not_ignored = _handler_that_records em_a
          end

          __handler_when_ignore ignore_h, when_ignored, when_not_ignored
        else

          mux_p
        end
      end

      def ___proc_for_when_ignored_under_mux aux_chan_p

        # ignoring means ignoring BUT if debugging is on then we ignore the
        # content but not the channel

        -> sym_a, & _ev_p do

          _em = IgnoredEmission___.new sym_a
          aux_chan_p[ _em ]

          UNRELIABLE_
        end
      end

      def __handler_when_ignore ignore_h, when_ignore_p, when_not_ignore_p

        ignore = -> sym_a do
          ignore_h[ sym_a.last ]
        end

        if when_ignore_p  # #OCD

          -> sym_a, & ev_p do

            if ignore[ sym_a ]
              when_ignore_p[ sym_a, & ev_p ]
            else
              when_not_ignore_p[ sym_a, & ev_p ]
            end

            UNRELIABLE_
          end
        else

          -> sym_a, & ev_p do

            if ! ignore[ sym_a ]
              when_not_ignore_p[ sym_a, & ev_p ]
            end

            UNRELIABLE_
          end
        end
      end

      def __handler_when_mux aux_chan_p, record

        -> sym_a, & p do

          _em = record[ sym_a, & p ]

          aux_chan_p[ _em ]

          UNRELIABLE_
        end
      end

      def _handler_that_records em_a

        -> chan, & em_p do

          em = if Looks_like_expression__[ chan ]
            ExpressionEmission___.new em_p, chan
          else
            EventEmission___.new em_p, chan
          end
          em_a.push em
          em
        end
      end
    end ; end

    # (the class graph below is vaguely tracked by :[#045]., has mentees)

    # ==

    class IgnoredEmission___

      def initialize chan
        @channel_symbol_array = [ :event_ignored, :expression, * chan ]
      end

      attr_reader(
        :channel_symbol_array,
      )

      def expression_proc
        This___
      end

      This___ = -> y do
        y << "«payload unavailable - this emission is ignored»"
      end

      def is_expression
        true
      end
    end

    # ==

    class EventEmission___

      def initialize p, chan
        @__event_proc = p
        @channel_symbol_array = chan
      end

      def _express_into_under_ y, expag
        _ev = cached_event_value
        _ev.express_into_under y, expag
      end

      def _trilean_
        cached_event_value.to_event.ok
      end

      def _event_or_lines_
        cached_event_value
      end

      def cached_event_value
        ( @___event_knownness ||= ___build_event_knownness ).value_x
      end

      def ___build_event_knownness
        _p = remove_instance_variable :@__event_proc
        _ev = _p.call
        Common_::Known_Known[ _ev ]
      end

      attr_reader(
        :channel_symbol_array,
      )

      def is_expression
        false
      end
    end

    # ==

    class ExpressionEmission___

      def initialize p, chan
        @channel_symbol_array = chan
        @expression_proc = p
      end

      def express_into_under y, expag
        expag.calculate y, & @expression_proc
      end

      alias_method :_express_into_under_, :express_into_under

      def _event_or_lines_
        ( @___1 ||= _kn( [], _black_and_white_expag )).value_x
      end

      def to_black_and_white_lines
        _expag = _black_and_white_expag
        _expag.calculate [], & @expression_proc
      end

      def to_black_and_white_line
        ( @___2 ||= _kn( "", _black_and_white_expag )).value_x
      end

      def _black_and_white_expag
        Black_and_white_expression_agent__[]
      end

      def _kn y, expag
        _y_ = expag.calculate y, & @expression_proc
        Common_::Known_Known[ _y_ ]
      end

      def _trilean_
        # ick not sure..
        ICK_NOT_SURE___.fetch @channel_symbol_array.fetch 0
      end

      ICK_NOT_SURE___ = {
        error: false,
        info: NIL,
        payload: NIL,  # EEK
      }

      attr_reader(
        :channel_symbol_array,
        :expression_proc,
      )

      def is_expression
        true
      end
    end

    # ==

    Black_and_white_expression_agent__ = Lazy_.call do
      Home_.lib_.brazen::API.expression_agent_instance
    end

    Codifying_expresion_agent__ = Lazy_.call do
      Home_::Event.codifying_expression_agent_instance
    end

    # ==

    Looks_like_expression__ = -> sym_a do  # #[#br-023]
      :expression == sym_a[ 1 ]
    end

    Say_unexpected_result__ = -> act_x, exp_x do
      "expected normal #{ Say_trilean__[ exp_x ] } result, #{
        }had #{ Say_not_trilean__[ act_x ] }"
    end

    Say_not_trilean__ = -> act_x do
      String_via_mixed__[ act_x ]
    end

    Say_trilean__ = -> x do
      Trilean_string_via_value___[].fetch x
    end

    State = ::Struct.new :result, :emission_array

    String_via_mixed__ = -> x do
      Home_.lib_.basic::String.via_mixed x
    end

    Trilean_string_via_value___ = Lazy_.call do
      {
        nil => "neutral",
        false => "negative",
        true => "positive",
      }
    end

    # ==

    Zerk_for_test_support_ = Lazy_.call do
      Autoloader_.require_sidesystem :Zerk
    end

    # ==

    BLACK_AND_WHITE_EXPEV_METHOD__ = :black_and_white_expression_agent_for_expect_emission
    DEBUGGING_EXPEV_METHOD__ = :expect_event_debugging_expression_agent
    EXPEV_METHOD__ = :expression_agent
    MY_EXPEV_METHOD__ = :expression_agent_for_expect_emission
    UNRELIABLE_ = :_unreliable_from_expect_event_
  end
end
# #tombstone-C: no more double-building. now when debugging events, etc
# #tombstone - event log was function soup
# #tombstone - simple debugging output
