module Skylab::Zerk::TestSupport

  module Expect_Screens  # objective & scope at [#006]

    PUBLIC = false  # a reminder that this is there

    def self.[] tcc
      tcc.extend Module_Methods___
      tcc.include self
    end

    module Module_Methods___

      def subject_ACS_class_ & p

        define_method :_expscr_subject_ACS_class, ( Lazy_.call do
          p[]
        end )
      end

      def input_ * x_a

        Danger_Memo__.call self, :_expscr_session_state do

          ___expscr_build_state x_a
        end
      end
    end

    Danger_Memo__ = TestSupport_::Define_dangerous_memoizer

    # -

      # -- specific whines

      def match_line_for_unrecognized_argument_ s
        eql "unrecognized argument #{ s.inspect }"
      end

      # -- matching buttons

      def look_like_a_line_of_buttons_
        match RX_FOR_LINE_OF_BUTTONS___
      end

      def hotstring_for_ slug
        buttons_.hotstring_for slug
      end

      def buttons_
        _expscr_session_state.screens.last.__buttons
      end

      def be_in_any_order_the_buttons_ * s_a

        o = Button_Set_Matcher__.new self
        o.slug_set = s_a
        o.slug_set_is_extent
        o
      end

      def have_button_for_ slug

        o = Button_Set_Matcher__.new self
        o.slug_set = [ slug ]
        o
      end

      # -- screen lines

      def first_line_
        _last_screen_line_strings.fetch 0
      end

      def second_line_
        _last_screen_line_strings.fetch 1
      end

      def last_line_
        _last_screen_line_strings.fetch( -1 )
      end

      def _last_screen_line_strings

        _expscr_session_state.screens.last.line_strings
      end

      def last_line_unchomped_

        # all lines are chomped because no lines are terminated (for now)

        _expscr_session_state.screens.last.line_strings.last
      end

      def unstyle_styled_ s
        Home_.lib_.brazen::CLI_Support::Styling::Unstyle_styled[ s ]
      end

      # -- internals

      def stack_

        # see #here

        _expscr_session_state.event_loop_state.frame_stack_length
      end

      def be_at_frame_number_ d

        # :#here build these two out to be like buttons w/ custom matchers
        # as soon as you validate more than this one aspect of the event loop

        eql d
      end

      # -- exitstatii

      def exitstatus_
        _expscr_session_state.end_result_wrapped_value.value_x
      end

      def be_successful_exitstatus_
        be_zero
      end

      # -- support - build state

      def ___expscr_build_state x_a

        _cls = _expscr_subject_ACS_class

        _CLI_class = Home_::CLI.new do | rsx, & ev_p |
          _cls.new rsx, & ev_p
        end

        fake = Custom_Fake___.new x_a, do_debug, debug_IO

        _CLI = _CLI_class.new fake.sin, SOUT_CANARY___, fake.serr, PN_S_A___

        event_loop = nil

        x = nil
        _got_to_end = catch :__expscr_freeze_where_you_are__ do

          x = _CLI.invoke EMPTY_A_ do | el |  # #NASTY
            event_loop = el
          end

          ACHIEVED_
        end

        if _got_to_end
          fake.accept_end_result x
        else
          _x = ___grind_the_event_loop event_loop
          fake.accept_that_we_froze_in_the_middle _x
        end

        fake.flush_to_state
      end

      def ___grind_the_event_loop event_loop

        _d = event_loop.instance_variable_get( :@_stack ).length

        Event_Loop_State___.new _d
      end

      Event_Loop_State___ = ::Struct.new :frame_stack_length
    # -

    PN_S_A___ = [ 'ziz' ]  # no see

    class Session_State___

      def initialize event_loop_state, end_result_wv, screens

        @end_result_wrapped_value = end_result_wv
        @event_loop_state = event_loop_state
        @screens = screens
      end

      attr_reader(
        :end_result_wrapped_value,
        :event_loop_state,
        :screens,
      )
    end

    class Screen___

      def initialize

        @_accept = method :__accept
        @line_strings = []
        @_pending = nil
      end

      def accept sym, s
        @_accept[ sym, s ]
      end

      def __accept sym, s

        if :line_string == sym

          s ||= EMPTY_S_  # some clients pass `nil` to get a newline

          if @_pending
            @_pending.concat s
            s = @_pending
            @_pending = nil
          end

          if ! s.frozen?
            s.freeze
          end

          @line_strings.push s
        else

          send :"__accept__#{ sym }__", s
        end
        NIL_
      end

      def __accept__write__ s
        if @_pending
          @_pending.concat s
        else
          @_pending = s.dup
        end
        NIL_
      end

      def close

        s = @_pending
        if s
          @_pending = nil
          @line_strings.push s
        end

        @_accept = Closed__
        @line_strings.freeze
        NIL_
      end

      # --

      def __buttons
        @___buttons ||= Hotstring_Index___.new( @line_strings.last )  # ..
      end

      attr_reader(
        :line_strings,
      )
    end

    class Button_Set_Matcher__

      def initialize tc
        @_is_extent = false
        @_tc = tc
      end

      def slug_set_is_extent
        @_is_extent = true
      end

      attr_writer(
        :slug_set,
      )

      def matches? buttons

        a = buttons.slug_list

        missing = @slug_set - a

        if @_is_extent
          extra = a - @slug_set
        end

        @_failures = nil

        if missing.length.nonzero?
          ___add_failure_of_missing_buttons missing
        end

        if extra && extra.length.nonzero?
          __add_failure_of_extra_buttons extra
        end

        if @_failures
          __fail a
        else
          ACHIEVED_
        end
      end

      def ___add_failure_of_missing_buttons missing
        _add_failure "missing required button(s) (#{ missing * ', ' })"
      end

      def __add_failure_of_extra_buttons extra
        _add_failure "unexpected button(s) (#{ extra * ', ' })"
      end

      def _add_failure s
        ( @_failures ||= [] ).push s ; nil
      end

      def __fail a

        _ = "#{ @_failures * ' and ' } in #{ a.inspect }"
        fail _
      end
    end

    class Hotstring_Index___

      def initialize line_string

        bx = Callback_::Box.new

        rx = EGADS_RX___ ; sp = BUTTON_SEPARATOR_RX___
        pos = 0

        parse_button = -> do

          md = rx.match line_string, pos

          a = [ * md.offset( :hotstring ), * md.offset( :rest ) ]

          a.map! do | d |
            d - pos
          end

          pos += md[ 0 ].length

          butt = Button___.new( a, md[ 0 ] )

          bx.add butt.slug, butt

          NIL_
        end

        last = line_string.length
        if last != pos

          parse_button[]

          begin
            if last == pos
              break
            end
            md = sp.match line_string, pos
            md or self._PARSE_FAILURE
            pos += md[ 0 ].length

            parse_button[]
            redo
          end while nil
        end

        @_buttons_box = bx.freeze
      end

      # --

      def hotstring_for slug

        @_buttons_box.fetch( slug ).hotstring
      end

      def slug_list
        @___sl ||= ___build_slug_list
      end

      def ___build_slug_list

        @_buttons_box.to_value_stream.map_by do | o |
          o.slug
        end.to_a
      end
    end

    class Button___

      def initialize a, s
        @_hotstring_range = ::Range.new( * a[ 0, 2 ], true )
        @_rest_range = ::Range.new( * a[ 2, 2], true )
        @_string = s
      end

      def slug
        @___slug ||= "#{ hotstring }#{ @_string[ @_rest_range ] }"
      end

      def hotstring
        @___hotstring ||= @_string[ @_hotstring_range ]
      end
    end

    EGADS_RX___ = /\G\[(?<hotstring>[a-z-]+)\](?<rest>[a-z-]*)/

    BUTTON_SEPARATOR_RX___ = /\G[ ]/

    butt = '\[[a-z-]+\][a-z-]*'

    RX_FOR_LINE_OF_BUTTONS___ = /\A#{ butt }(?: #{ butt })*\z/

    class Custom_Fake___

      def initialize x_a, do_debug, debug_IO

        __init_begin_new_screen_proc

        @_do_debug = if do_debug
          @_debug_IO = debug_IO
          do_debug
        end

        @serr = ___build_fake_serr

        @sin = __build_fake_sin x_a

      end

      # -- fake serr

      def ___build_fake_serr

        @_receive = -> sym, ss do

          _begin_new_screen

          @_receive[ sym, ss ]
        end

        io = Fake_Writable_IO__.new

        io.on_puts = -> s do
          @_receive[ :line_string, s ]
          NIL_
        end

        io.on_write = -> s do
          @_receive[ :write, s ]
          s.length
        end

        io
      end

      # -- fake sin

      def __build_fake_sin x_a

        io = Fake_Readable_IO___.new

        st = Callback_::Polymorphic_Stream.via_array x_a

        lineify = -> s do

          # all to-be-sent lines as represented in input are "line strings"
          # why (by definition) do not have line terminating sequences (and
          # they must have them to mimic `gets`)

          # furthermore we nastily take this moment here to signify a
          # "screen break" (like a page break)

          _begin_new_screen

          "#{ s }#{ NEWLINE_ }"
        end

        freeze = -> do
          throw :__expscr_freeze_where_you_are__, STOPPED_  # #EGADS
        end

        fake_interrupt = -> x do
          x  # should be fine as-is per [#002]#detail-two
        end

        if @_do_debug

          dbg = @_debug_IO

          p = lineify
          lineify = -> s do
            line = p[ s ]
            dbg.puts "(SEND: #{ line.inspect })"
            line
          end

          p_ = freeze
          freeze = -> do
            dbg.puts "(SEND: doing the freeze hack with the throw)"
            p_[]
          end

          p3 = fake_interrupt
          fake_interrupt = -> x do
            dbg.puts "(SEND: fake interrput signal (actually #{ x.inspect })"
            p3[ x ]
          end
        end

        io.on_gets = -> do

          if st.no_unparsed_exists
            freeze[]
          else
            x = st.gets_one
            if x
              lineify[ x ]
            else
              fake_interrupt[ x ]
            end
          end
        end

        io
      end

      # -- support above

      def _begin_new_screen
        @_begin_new_screen[]
        NIL_
      end

      def __init_begin_new_screen_proc

        @_begin_new_screen = -> do
          # first time it is called
          @_screens = []
          _add_new_screen

          @_begin_new_screen = -> do
            # each subsequent time it is called
            @_screens.last.close
            _add_new_screen
            NIL_
          end

          NIL_
        end
        NIL_
      end

      def _add_new_screen

        screen = Screen___.new
        @_screens.push screen

        p = -> sym, s do

          screen.accept sym, s
          NIL_
        end

        if @_do_debug
          dbg = @_debug_IO
          p0 = p
          p = -> sym, s do
            if :line_string != sym
              _ = " #{ sym }"
            end
            dbg.puts "(RECV#{ _ }: #{ s.inspect })"
            p0[ sym, s ]
          end
        end

        @_receive = p
        NIL_
      end

      # -- near end & end

      def accept_end_result x
        @_did_get_to_end  = true
        @_end_result = x ; nil
      end

      def accept_that_we_froze_in_the_middle els
        @_did_get_to_end = false
        @_event_loop_state = els ; nil
      end

      def flush_to_state

        remove_instance_variable :@_begin_new_screen

        do_dbg = remove_instance_variable :@_do_debug
        if do_dbg
          remove_instance_variable :@_debug_IO
        end

        remove_instance_variable :@_receive
        remove_instance_variable( :@serr ).close_fake_IO
        remove_instance_variable( :@sin ).close_fake_IO

        # assume always at least one screen

        if remove_instance_variable( :@_did_get_to_end )

          _x = remove_instance_variable :@_end_result
          end_result_wv = Callback_::Known_Known[ _x ]

        else

          @_screens.last.close
          end_result_wv = Callback_::KNOWN_UNKNOWN
          els = remove_instance_variable :@_event_loop_state
        end

        _a = remove_instance_variable( :@_screens ).freeze

        instance_variables.length.zero? or self._OCD_ABOUT_IVARS

        Session_State___.new(
          els,
          end_result_wv,
          _a,
        )
      end

      attr_reader(
        :serr,
        :sin,
      )
    end

    class Fake_Writable_IO__ < ::BasicObject

      # #[#ts-020] watch and learn

      attr_writer(
        :on_puts,
        :on_write,
      )

      def puts s
        @on_puts[ s ]
      end

      def write s
        @on_write[ s ]
      end

      def close_fake_IO
        @on_puts = Closed__ ; nil
      end
    end

    say_expected_none = -> s=nil do

      _ = if s
        " (had: #{ s.inspect }"
      end

      "expected no input to this IO stream#{ _ }."
    end

    o = Fake_Writable_IO__.new

    o.on_puts = -> s do
      fail say_expected_none[ s ]
    end

    SOUT_CANARY___ = o

    class Fake_Readable_IO___ < ::BasicObject

      attr_writer(
        :on_gets,
      )

      def gets
        @on_gets.call
      end

      def close_fake_IO
        @on_gets = Closed__ ; nil
      end
    end

    Closed__ = -> * do
      fail "attempt to write to fake after fake was closed"
    end

    STOPPED_ = false
  end
end
