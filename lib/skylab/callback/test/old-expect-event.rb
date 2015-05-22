module Skylab::Callback::TestSupport

  module Old_Expect_Event

    class Assertion  # read [#021] the .. narrative #storypoint-005

      def initialize x_a
        @did_pass = true ; @do_continue = true
        @exp = nil ; @exp_x_a = x_a
        @fail_s_a = @fail_message_yielder = @legacy_string_map_p = nil
        super()
      end

      def set_exp exp
        @exp  = exp ; nil
      end

      def set_fail_message_yielder y
        @fail_message_yielder and fail "won't clobber - set to nil first"
        @fail_message_yielder = y ; nil
      end

      def will_assert_against act_x
        @act_x = act_x ; nil
      end

      def assert_under client
        @fail_message_yielder and fail "can't assert under when f.m.y is set"
        match @act_x
        if ! @did_pass
          client.send :fail, failure_message_for_should
        end ; nil
      end

      def description
        @exp.get_some_description_string
      end

      def failure_message_for_should
        @fail_s_a && @fail_s_a * '. '
      end

      def match actual_a
        @actual_a = actual_a
        prep_expectation
        exec_expectation
        @did_pass
      end

      def fail_with_msg s
        fail_w_message s
      end

      def fail_with_non_any_redundant_message_about_missing_el_at_idx d
        fail_w_non_rdndnt_msg_aobut_missing_element_at_index d
      end
    private
      def prep_expectation
        if @exp_x_a
          @exp = Expectation.new @exp_x_a ; @exp_x_a = nil
        end
        @actual_index = rslv_some_actual_index
        init_event_proxy ; nil
      end
      def rslv_some_actual_index
        if @exp.index_was_specified
          @exp.specified_index
        else
          @actual_a.length.zero? ? false : @actual_a.length - 1
            # the default item of focus is the last item in the queue
        end
      end
      def init_event_proxy
        @event_proxy = @actual_index && bld_event_proxy
      end
      def bld_event_proxy
        ep = Event_Proxy__.new @actual_index, @actual_a
        if @legacy_string_map_p
          s = ep.any_matchable_string
          if s
            @legacy_string_map_p.call s do |s_|
              ep.change_matchable_string! s_
            end
          end
        end
        ep
      end
    public
      def set_legacy_string_map_proc p
        @legacy_string_map_p = p ; nil
      end
    private
      def exec_expectation
        scn = @exp.get_element_stream
        while (( el = scn.gets ))
          exec_element el
          @do_continue or break
        end
        exec_after_scan ; nil
      end
      def exec_element el
        _assertion = el.build_assertion_for self
        _assertion.see @event_proxy ; nil
      end
      def exec_after_scan
        if ! @exp.index_was_specified && 1 != @actual_a.length
          fail_w_non_rdndnt_msg_aobut_missing_element_at_index 0
        end ; nil
      end
      def fail_w_non_rdndnt_msg_aobut_missing_element_at_index d
        @did_complain_about_no_event ||= msg_ev d
      end
      def msg_ev d
        s = 's' if d.nonzero?
        fail_w_message "expected #{ d + 1 } event#{ s }, #{
          }had #{ @actual_a.length }" ; true
      end
      def fail_w_message s
        @did_pass = false
        fail_msg_yielder << s ; nil
      end
      def fail_msg_yielder
        @fail_message_yielder ||= bld_fail_message_yielder
      end
      def bld_fail_message_yielder
        @fail_s_a ||= []
        ::Enumerator::Yielder.new do |s|
          @fail_s_a << s
        end
      end
    end

    class Event_Proxy__
      def initialize idx, act_a
        @index = idx ; @len = act_a.length
        @matchable_string_was_mutated = false
        @s = nil ; @up = act_a[ idx ] ; nil
      end
      attr_reader :index
      def stream_symbol
        @up.stream_symbol
      end
      def any_matchable_string
        @matchable_string_was_mutated ? @s : ( @up.payload_x if @up )
      end
      def matchable_string
        @matchable_string_was_mutated ? @s : @up.payload_x
      end
      def length
        @len
      end

      def change_matchable_string! s
        @matchable_string_was_mutated = true ; @s = s ; nil
      end
    end

    class Expectation

      def initialize x_a
        y = []
        @index_was_specified = false ; @symbol_count = 0
        x_a.each_with_index do |x, d|
          @last_index = d
          y << From__.const_get( x.class.name.intern, false ).new( self, x, d )
        end
        @exp_a = y.freeze
        super()
      end
      attr_reader :index_was_specified, :specified_index
      def change_actual_index_to d
        @index_was_specified and raise "#{
          }cannot stack assertions for multiple indices"
        @index_was_specified = true
        @specified_index = d ; nil
      end
      def increment_symbol_count
        @symbol_count += 1
      end
      def get_some_description_string
        scn = get_element_stream
        h = { }
        while (( el = scn.gets ))
          h[ el.description_slot_i ] = el.description_x
        end
        h.length.zero? ? 'nothing' : rslv_dsc_str( h )
      end
      def rslv_dsc_str h
        _output_s = TEMPLATE_S__.gsub Callback_.lib_.string_lib.mustache_regexp do
          did_have = true
          x = h.fetch $1.intern do did_have = nil end
          did_have and " #{ x }"
        end
        _output_s
      end

      TEMPLATE_S__ = 'emit{{pos}}{{adj}}{{channel}}{{msg}}'.freeze

      def get_element_stream
        d = -1 ; last = @exp_a.length - 1
        Callback_::Scn.new do
          if d < last
            @exp_a[ d += 1 ]
          end
        end
      end

      module Assertion_Methods__
        def initialize_assertion assertion
          @up_p = -> { assertion } ; nil
        end
        def see x
          if x
            see_when_event x
          else
            fail_w_msg_about_how_there_is_no_event
          end
        end
      private
        def fail_with_message msg
          @up_p[].fail_with_msg msg ; nil
        end
        def fail_w_msg_about_how_there_is_no_event
          @up_p[].fail_with_non_any_redundant_message_about_missing_el_at_idx 0
        end
      end

      class From__

        def self.description_slot_i i
          define_method :description_slot_i do i end ; nil
        end

        attr_reader :description_x

        def build_assertion_for assertion
          copy = dupe
          copy.extend Assertion_Methods__
          copy.initialize_assertion assertion
          copy
        end
      private
        def dupe
          dup
        end

        class Fixnum < self
          def initialize up, d, idx
            up.change_actual_index_to d
            @d = d ; @idx = idx
            _ord_s = if -1 == d then LAST_S_ else
              Callback_.lib_.basic::Number::EN.num2ord( d + 1 )
            end
            @description_x = '%-6s' % _ord_s
            super()
          end
          description_slot_i :pos
          def see_when_event act
          end
        end
        class NilClass < self  # #storypoint-500
          def initialize up, _, idx
            @description_x = "no more events."
            @index = idx ; super()
          end
          description_slot_i :channel
          def see_when_event act
            if act.index != act.length
              s = 's' if 1 != @index
              fail_with_message "expected exactly #{ @index } event#{ s }, #{
                }had #{ act.length }"
            end ; nil
          end
        end
        class Regexp < self
          def initialize up, rx, _idx
            @rx = rx ; @description_x = rx.inspect ; super()
          end
          description_slot_i :msg
          def see_when_event act
            act_s = act.matchable_string
            if @rx =~ act_s
              @description_x = act_s.inspect
            else
              fail_with_message "expected text to match #{ @rx.inspect }, #{
                }had #{ act_s.inspect }"
            end ; nil
          end
        end
        class String < self
          def initialize up, s, _idx
            @description_x = s.inspect ; @s = s ; super()
          end
          description_slot_i :msg
          def see_when_event act
            act_s = act.matchable_string
            if @s != act_s
              fail_with_message "expected text #{ @s.inspect }, #{
                }had #{ act_s.inspect }"
            end ; nil
          end
        end
        module Symbol
          def self.new up, i, _idx
            cnt = up.increment_symbol_count
            if 1 == cnt
              Channel_Assertion__.new i
            else
              :styled == i or raise ::ArgumentError, "expected 'styled' #{
                }had #{ Callback_.lib_.strange x }"
              STYLED_ASSERTION__
            end
          end
        end
      end
      class Channel_Assertion__ < From__
        def initialize i
          @description_x = i.inspect
          @i = i
          super()
        end
        description_slot_i :channel
        def see_when_event act
          act_i = act.stream_symbol
          if @i != act_i
            fail_with_message "expected stream_symbol #{ @i.inspect }, #{
              }had #{ act_i.inspect }"
          end ; nil
        end
      end
      STYLED_ASSERTION__ = class Styled_Assertion__ < From__
        def initialize
        end
        description_slot_i :adj
        def description_x ; STYLED__ end
        STYLED__ = 'styled'.freeze
        def see_when_event act
          s = act.matchable_string
          s_ = Callback_.lib_.CLI_lib.unstyle_styled s
          if s_
            act.change_matchable_string! s_
          else
            fail_with_message "expected string to be styled, was not: #{ s }"
          end ; nil
        end
        self
      end.new
      LAST_S_ = 'last'.freeze
    end
  end
end
## HERE ##
# the below mess is for some ANCIENT [po] tests that we want desparately to go away
module Skylab::Callback::TestSupport
  module Old_Expect_Event
    Predicate = ::Module
    class Predicate::Nub  # #retro-fitter. may be temporary.
      def initialize exp_a
        @ass = Assertion.new exp_a
      end
      def textify= p
        @ass.set_legacy_string_map_proc -> s, &p_ do
          p_[ p[ s ] ] ; nil
        end ; p
      end
      def unstyle_all_styled!
        @ass.set_legacy_string_map_proc -> s, &p do
          s_ = Callback_.lib_.CLI_lib.unstyle_styled s
          s_ and p[ s_ ] ; nil
        end ; nil
      end
      def handle_match
        method :match_notify
      end
      def match_notify x
        @ass.match x
      end
      def handle_failure_message_for_should
        method :fmfs_notify
      end
      def fmfs_notify
        @ass.failure_message_for_should
      end
      def handle_description
        method :description_notify
      end
      def description_notify
        @ass.description
      end
    end
  end
end
