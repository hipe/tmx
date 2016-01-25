module Skylab::Callback::TestSupport

  module Expect_Event  # [#065] (has subscribers to the rewrite)

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

    IGNORE_METHOD__ = :_hash_of_terminal_channels_for_expev_to_ignore

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

        def call_API_via_iambic x_a, & x_p
          if ! block_given?
            _oes_p = event_log.handle_event_selectively
            x_a.push :on_event_selectively, _oes_p
          end
          @result = subject_API.call( * x_a, & x_p )
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

        # ~ expectations along the different qualities of events

        def black_and_white ev
          black_and_white_lines( ev ).join NEWLINE_
        end

        def black_and_white_lines ev
          _expag = __expev_upper_level_expression_agent
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
          expect_failed
          em
        end

        def expect_failed
          __expev_expect_failed_result
          _expect_no_next_actual_expev_emission
        end

        def expect_neutralled
          expect_neutral_result
          _expect_no_next_actual_expev_emission
        end

        def expect_succeeded
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

    Callback_ = Home_  # b.c we keep forgetting ..

    module Test_Context_Instance_Methods

      # -- flush state

      def flush_event_log_and_result_to_state x

        _a = remove_instance_variable( :@event_log ).flush_to_array
        Common_State___.new x, _a
      end

      Common_State___ = ::Struct.new :result, :emission_array

      # -- log-based event testing

      def event_log
        @event_log ||= build_event_log  # ivar name is #public-API
      end

      def build_event_log

        log = Event_Log___.new

        if do_debug
          log.set_auxiliary_listener_by( & __build_expev_debug_auxil_proc )
        end

        h = send IGNORE_METHOD__
        if h
          log.set_hash_of_terminal_channels_to_ignore h
        end

        log
      end

      define_method IGNORE_METHOD__ do
        NIL_
      end

      def __build_expev_debug_auxil_proc

        io = debug_IO

        -> i_a, & _ev_p do
          io.puts i_a.inspect
          UNRELIABLE_
        end
      end

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

      def expect_no_emissions
        emission_count.should be_zero
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

      def last_emission
        emission_array.last
      end

      def emission_array
        state_.emission_array
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

      def __expev_expag_for_reification
        _expev_lower_level_expression_agent
      end

      lazy = Callback_::Lazy

      define_method :__expev_upper_level_expression_agent, -> do

        m = :black_and_white_expression_agent_for_expect_event

        -> do
          if respond_to? m
            send m
          else
            default_black_and_white_expression_agent_for_expect_event
          end
        end
      end.call

      define_method(
        :default_black_and_white_expression_agent_for_expect_event,
        ( lazy.call do
          Home_.lib_.brazen::API.expression_agent_instance
        end ),
      )

      define_method :_expev_lower_level_expression_agent, -> do

        m = :expression_agent_for_expect_event

        -> do
          if respond_to? m
            send m
          else
            default_expression_agent_for_expect_event
          end
        end
      end.call

      define_method :default_expression_agent_for_expect_event, ( lazy.call do
        Home_::Event.codifying_expression_agent_instance
      end )
    end

    # -

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

        if @_expectation.trilean_value != @_emission.cached_event_value.to_event.ok

          _add_failure_by do

            _exp_x = @_expectation.trilean_value
            _act_x = @_emission.cached_event_value.to_event.ok

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

        act = @_emission.channel_symbol_array
        exp = @_expectation.full_channel

        Require_basic__[]
        good_d = Basic_::List.index_of_deepest_common_element act, exp

        # if the actual channel is deeper than the expected channel,
        # but the expect channel matches the head-anchored slice, it's still
        # a match (FOR NOW)..

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

      Require_basic__ = Callback_::Lazy.call do
        Basic_ = Home_.lib_.basic
        NIL_
      end

      def ___say_detailed_explanation_about_channel_mismatch bad_d, act, exp

        ba = Basic_

        _ord = ba::Number::EN.num2ord bad_d + 1

        _had_x = ba::String.via_mixed act[ bad_d ]  # any
        _need_x = ba::String.via_mixed exp[ bad_d ]  # any

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

        # this experiment messes with state and reaches outside of silos
        # for the convenience of getting an array of strings built under
        # a particular expag when the emission is of shape "expression".
        # it assume the emission has not been reified yet.

        p = @_expectation.alternate_user_proc
        em = @_emission

        if Looks_like_expression__[ em.channel_symbol_array ]

          _expag = @_test_context._expev_lower_level_expression_agent

          em.reify_by do | ev_p |

            _expag.calculate( [], & ev_p ).freeze
          end
        end

        p[ em.cached_event_value ]

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

        _lines = @_emission.cached_event_value.express_into_under [], _expag

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

    class Event_Log___

      # at present this wraps multiple concerns and implements them with
      # function soup.
      #
      #   advantage: it serves as a front for this whole API, allowing the
      #     client (the test context) to clutter its ivar namespace with
      #     only this one name (and its concept-space with only this object.)
      #
      #   disadvantage: it violates the Single Responsibility Principle.
      #
      # so its implementation **and interface** is an experiment vulnerable
      # to (yet more) change..

      def initialize

        # -- set options

        opts = nil
        @_receive_option = -> sym, x do
          opts ||= Options___.new
          opts[ sym ] = x ; nil
        end

        # -- log emissions

        a = []

        close_options = -> do  # idempotent
          @_receive_option = nil
        end

        receive_emission = -> symbol_array, & event_proc do

          close_options[]

          record = __proc_for_record a

          receive_emission = if opts
            __proc_when_options opts, record
          else
            record
          end

          receive_emission[ symbol_array, & event_proc ]
        end

        @handle_event_selectively = -> * i_a, & ev_p do
          receive_emission[ i_a, & ev_p ]
          UNRELIABLE_
        end

        # -- read emissions

        close_options_and_readers = -> do

          close_options[]
          receive_emission = nil

          @_flush_to_scanner = nil
          @_flush_to_array = nil
          @_gets_x = nil
        end

        @_flush_to_scanner = -> do
          close_options_and_readers[]
          Callback_::Polymorphic_Stream.via_array a
        end

        @_flush_to_array = -> do
          close_options_and_readers[]
          a.freeze
        end

        @_gets_x = -> do

          # this ivar could be made to be immutable **but it is NOT currently**

          close_options_and_readers[]
          @_gets_x = Callback_::Stream.via_nonsparse_array a
          @_gets_x.call
        end
      end

      # -- set options (counterpart)

      def set_auxiliary_listener_by & aux_chan_p
        @_receive_option[ :aux_listener, aux_chan_p ]
        NIL_
      end

      def set_hash_of_terminal_channels_to_ignore h
        @_receive_option[ :ignore_term_chan_hash, h ]
        NIL_
      end

      # -- log emissions (counterpart)

      attr_reader(
        :handle_event_selectively,
      )

      def __proc_when_options opts, record

        aux_chan_p = opts.aux_listener
        ignore_h = opts.ignore_term_chan_hash

        if aux_chan_p
          mux_p = __proc_for_mux aux_chan_p, record
        end

        if ignore_h

          if aux_chan_p
            when_ignored = ___proc_for_when_ignored_under_mux aux_chan_p
            when_not_ignored = mux_p
          else
            when_not_ignored = record
          end

          __if_ignore ignore_h, when_ignored, when_not_ignored
        else

          mux_p
        end
      end

      Options___ = ::Struct.new :aux_listener, :ignore_term_chan_hash

      def ___proc_for_when_ignored_under_mux aux_chan_p

        -> sym_a, & ev_p do

          aux_chan_p.call( [ :event_ignored, * sym_a ] ) do
            self._DESIGN_ME
          end

          UNRELIABLE_
        end
      end

      def __if_ignore ignore_h, when_ignore_p, when_not_ignore_p

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

      def __proc_for_mux aux_chan_p, record

        -> sym_a, & p do

          _unreliable = record[ sym_a, & p ]

          aux_chan_p.call sym_a do
            self._DESIGN_ME
          end

          UNRELIABLE_
        end
      end

      def __proc_for_record em_a

        -> sym_a, & ev_p do

          _em = Emission___.new ev_p, sym_a
          em_a.push _em
          UNRELIABLE_
        end
      end

      # -- read emissions (counterpart)

      def flush_to_scanner
        @_flush_to_scanner[]
      end

      def flush_to_array
        @_flush_to_array[]
      end

      def gets
        @_gets_x.call
      end
    end

    class Emission___

      def initialize event_proc, channel_symbol_array

        @channel_symbol_array = channel_symbol_array
        @_needs_reification = true
        @_x_p = event_proc
      end

      def cached_event_value
        if @_needs_reification
          ___reify
          @_needs_reification = false
        end
        @_x
      end

      def reify_by & do_this

        _p = remove_instance_variable :@_x_p

        @_needs_reification = false

        @_x = do_this[ _p ]

        NIL_
      end

      def ___reify

        p = remove_instance_variable :@_x_p

        @_x = if Looks_like_expression__[ @channel_symbol_array ]
          Expression_as_Event___.new( p, @channel_symbol_array.last )
        else
          p[]
        end
        NIL_
      end

      attr_reader(
        :channel_symbol_array,
      )
    end

    class Expression_as_Event___

      def initialize y_p, sym
        @terminal_channel_symbol = sym
        @_y_p = y_p
      end

      def express_into_under y, expag
        expag.calculate y, & @_y_p
      end

      attr_reader(
        :terminal_channel_symbol,
      )

      def to_event
        self
      end

      def ok
        NIL_
      end
    end

    Looks_like_expression__ = -> sym_a do  # #[#br-023]
      :expression == sym_a[ 1 ]
    end

    Say_unexpected_result__ = -> act_x, exp_x do
      "expected normal #{ Say_trilean__[ exp_x ] } result, #{
        }had #{ Say_not_trilean__[ act_x ] }"
    end

    Say_not_trilean__ = -> act_x do
      Home_.lib_.basic::String.via_mixed act_x
    end

    Say_trilean__ = -> x do
      Trilean_string_via_value___[].fetch x
    end

    Trilean_string_via_value___ = Callback_::Lazy.call do
      {
        nil => "neutral",
        false => "negative",
        true => "positive",
      }
    end

    ACHIEVED_ = true
    UNRELIABLE_ = false
  end
end
