module Skylab::Zerk::TestSupport

  module Expect_Screens  # objective & scope at [#006]

    # (unofficially this node is sometimes associated with
    # the name/prefix "iCLI" as well as "expect_screens")

    PUBLIC = true  # [sa]

    def self.[] tcc

      tcc.extend Module_Methods___

      tcc.include Instance_Methods___

      x = nil
      tcc.send :define_method, :__expscr_test_suite_shared_resources do
        x ||= {}
      end
    end

    module Module_Methods___

      def given & p

        TestSupport_::Define_dangerous_memoizer.call self, :iCLI_state do

          @_expscr_inputs = Inputs___.new
          instance_exec( & p )
          __expscr_build_state remove_instance_variable :@_expscr_inputs
        end
      end

      def screen d
        define_method :screen do
          screens.fetch d
        end
      end
    end

    module Instance_Methods___

      def subject_CLI

        cache = __expscr_test_suite_shared_resources
        cache.fetch :_subject_CLI do
          x = build_interactive_CLI_classeque
          cache[ :_subject_CLI ] = x
          x
        end
      end

      def build_interactive_CLI_classeque

        cli = Home_::Interactive_CLI.begin

        cli.root_ACS = method :build_root_ACS_for_expect_screens

        cli.to_classesque
      end

      def build_root_ACS_for_expect_screens  # ignore oes_p

        _ = subject_root_ACS_class
        _.new_cold_root_ACS_for_iCLI_test  # #cold-model
      end

      def stdout_is_expected_to_be_written_to
        false
      end

      # -- specific whines

      def match_line_for_unrecognized_argument_ s
        eql "unrecognized argument #{ s.inspect }"
      end

      # -- matching buttons

      def look_like_a_line_of_buttons_
        match RX_FOR_LINE_OF_BUTTONS___
      end

      def hotstring_for slug
        buttonesques.hotstring_for slug
      end

      def buttonesques
        iCLI_state.screens.last.buttonesques
      end

      def be_in_any_order_the_buttons_ * s_a

        o = Button_Set_Matcher__.new self
        o.slug_set = s_a
        o.slug_set_is_extent
        o
      end

      def not_have_button_for slug  # ..
        o = have_button_for slug
        o.negate!
        o
      end

      def have_button_for slug

        o = Button_Set_Matcher__.new self
        o.slug_set = [ slug ]
        o
      end

      def include_in_any_order_the_buttons * s_a

        o = Button_Set_Matcher__.new self
        o.slug_set = s_a
        o
      end

      # -- screen lines

      def first_line
        lines.fetch 0
      end

      def second_line
        lines.fetch 1
      end

      def last_line_not_chomped_  # (in case there is ever a difference)
        lines.fetch( -1 )
      end

      def last_line
        lines.fetch( -1 )
      end

      def lines
        screen.__all_lines
      end

      def first_screen
        screens.first
      end

      def second_screen
        screens.fetch 1
      end

      def screen
        screens.last
      end

      def screens
        iCLI_state.screens
      end

      def _expscr_last_screen_stream_lines_stream
        Callback_::Stream.via_nonsparse_array _expscr_last_screen_stream_lines 
      end

      def _expscr_last_screen_stream_lines
        iCLI_state.screens.fetch( -1 ).stream_lines
      end

      def unstyle_styled_ s
        Remote_CLI_lib_[]::Styling::Unstyle_styled[ s ]
      end

      def entity_item_table_simple_regex
        This_rx___[]
      end

      This_rx___ = Lazy_.call do
        /\A +([^ ]+)(?:  +([^ ].*))?\z/
      end

      # -- testing which frame you are on

      def stack

        # see #here

        iCLI_state.event_loop_state.frame_stack_length
      end

      def be_at_frame_number d

        # :#here build these two out to be like buttons w/ custom matchers
        # as soon as you validate more than this one aspect of the event loop

        eql d
      end

      # -- exitstatii

      def exitstatus_
        iCLI_state.end_result_wrapped_value.value_x
      end

      def be_successful_exitstatus_
        be_zero
      end

      # -- support - build state

      def cli & p
        @_expscr_inputs.__freeform_mutation_proc = p ; nil
      end

      def filesystem_conduit_of x
        @_expscr_inputs.__filesystem_conduit = x ; nil
      end

      def system_conduit_of x
        @_expscr_inputs.__system_conduit = x ; nil
      end

      def input( * x_a )
        @_expscr_inputs.__CLI_x_a = x_a ; nil
      end
    end

      Inputs___ = ::Struct.new(  # (here b.c used in next method)
        :__CLI_x_a,
        :__filesystem_conduit,
        :__freeform_mutation_proc,
        :__system_conduit,
      )

    module Instance_Methods___

      def __expscr_build_state sct

        x_a = sct.__CLI_x_a
        muta_p = sct.__freeform_mutation_proc

        fake = Custom_Fake___.new x_a, do_debug, debug_IO

        if stdout_is_expected_to_be_written_to
          fake.init_sout_like_serr
        else
          fake.sout = SOUT_CANARY___
        end

        cli = __expscr_build_CLI fake

        prepare_CLI_for_expect_screens(
          cli, sct.__filesystem_conduit, sct.__system_conduit )

        if muta_p
          muta_p[ cli ]
        end

        event_loop = nil
        x = nil

        cli.on_event_loop = -> el do
          event_loop = el
        end

        _got_to_end = catch :__expscr_freeze_where_you_are__ do

          x = cli.invoke EMPTY_A_
          ACHIEVED_
        end

        if _got_to_end
          fake.accept_end_result x
        else
          _x = ___expscr_grind_the_event_loop event_loop
          fake.accept_that_we_froze_in_the_middle _x
        end

        fake.flush_to_state
      end

      def prepare_CLI_for_expect_screens cli, fc, sc

        if fc
          cli.filesystem_conduit = fc
        end

        if sc
          cli.system_conduit = sc
        end

        NIL_
      end

      def ___expscr_grind_the_event_loop event_loop

        d = 0
        tf = event_loop.top_frame
        while tf
          d += 1
          tf = tf.below_frame
        end

        Event_Loop_State___.new d
      end

      Event_Loop_State___ = ::Struct.new :frame_stack_length

      def __expscr_build_CLI fake

        _CLI_class = subject_CLI

        _CLI_class.new fake.sin, fake.sout, fake.serr, PN_S_A___
      end

      PN_S_A___ = [ 'ziz' ]  # no see

    end

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

        @_accept = -> m, x do
          send m, x
        end
        @_serr_buff = nil
        @_stream_lines = []
      end

    # -- readers (some that cache (lazily))

      def count_lines_on sym
        _to_stream_line_stream_on( sym ).flush_to_count
      end

      def serr_lines
        @___serr_lines ||= to_content_line_stream_on( :serr ).to_a
      end

      def __all_lines
        @___all_lines ||= _to_stream_line_stream( & :line_string ).to_a
      end

      def to_content_line_stream_on sym
        _to_stream_line_stream_on( sym ).map_by( & :line_string )
      end

      def _to_stream_line_stream_on sym
        _to_stream_line_stream.reduce_by do |o|
          sym == o.stream_symbol
        end
      end

      def _to_stream_line_stream & p
        Callback_::Stream.via_nonsparse_array( @_stream_lines, & p )
      end

      def first_line_content
        @_stream_lines.fetch( 0 ).line_string
      end

      # ~

      def buttonesques
        @___buttons ||= ___build_buttons
      end

      def ___build_buttons
        o = @_stream_lines.last
        if :serr != o.stream_symbol
          self._LAST_LINE_SHOULD_ALWAYS_BE_ON_SERR
        end
        Hotstring_Index___.new( o.line_string )  # ..
      end

    # -- writers (while open only)

      def __accept sym, s
        @_accept[ sym, s ]
      end

      # ~ internal for writing
      private

      def sout_line_string s
        s or self._WEIRD

        if ! s.frozen?
          s.freeze
        end

        __accept_sout_line_string s
        NIL_
      end

      def serr_line_string s

        s ||= EMPTY_S_  # some clients pass `nil` to get a newline

        if @_serr_buff
          @_serr_buff.concat s
          _flush_serr_buff
        else
          _accept_serr_line_string s
        end

        NIL_
      end

      def serr_write s

        if @_serr_buff
          @_serr_buff.concat s
        else
          @_serr_buff = s.dup
        end
        _flush_serr_buff
        NIL_
      end

      # ~ exposures for writing
      public

      def _close_screen

        if @_serr_buff
          __close_serr_buff
        end

        @_accept = Closed__
        @_stream_lines.freeze
        NIL_
      end

      def __close_serr_buff  # assume
        _flush_serr_buff
        s = @_serr_buff
        if s
          @_serr_buff = nil
          _accept_serr_line_string s  # LOSSY
        end
        NIL_
      end

      def _flush_serr_buff  # assume
        d = @_serr_buff.index NEWLINE_
        if d
          __do_flush_serr_buff d
        end
        NIL_
      end

      def __do_flush_serr_buff d  # (this again)

        s = @_serr_buff
        len = s.length
        pos = 0
        begin
          _accept_serr_line_string s[ pos, d - pos ]  # effectively chomp
          pos = d + 1
          if len == pos
            done = true
            break
          end
          d = s.index NEWLINE_
          if d
            self._COVER_ME
          else
            break
          end
        end while nil

        if done
          @_serr_buff = nil
        end
      end

      def __accept_sout_line_string s
        @_stream_lines.push Stream_Line__[ s, :sout ] ; nil
      end

      def _accept_serr_line_string s
        @_stream_lines.push Stream_Line__[ s, :serr ] ; nil
      end
    end

    Stream_Line__ = ::Struct.new :line_string, :stream_symbol
      # #[#ts-007] (2 of 2 in universe)

    class Button_Set_Matcher__

      def initialize tc
        @_is_extent = false
        @_polarity = true
        @_tc = tc
      end

      def slug_set_is_extent
        @_is_extent = true
      end

      def negate!
        @_polarity = false ; nil
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

        if missing.length.zero?
          if ! @_polarity
            ___when_had_blacklisted_button missing
          end
        elsif @_polarity
          ___when_missing_buttons missing
        end

        if extra && extra.length.nonzero?
          __when_extra_buttons extra
        end

        if @_failures
          __fail a
        else
          ACHIEVED_
        end
      end

      def ___when_had_blacklisted_button x
        _add_failure "found blacklisted button(s) (#{ x * ', '})"
      end

      def __when_missing_buttons x
        _add_failure "missing required button(s) (#{ x * ', ' })"
      end

      def __when_extra_buttons x
        _add_failure "unexpected button(s) (#{ x * ', ' })"
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

      def initialize serr_line_string

        bx = Callback_::Box.new

        rx = EGADS_RX___ ; sp = BUTTON_SEPARATOR_RX___
        pos = 0

        parse_button = -> do

          md = rx.match serr_line_string, pos

          md or fail

          butt = Button___.new md, serr_line_string

          pos = md.offset( 0 ).last  # advance the pointer to the first
            # cel after the end of the button (or off the end of the string)

          bx.add butt.slug, butt

          NIL_
        end

        last = serr_line_string.length
        if last != pos

          parse_button[]

          begin
            if last == pos
              break
            end
            md = sp.match serr_line_string, pos
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

      def initialize md, s

        translate = -> sym do
          a = md.offset sym
          if a.first
            ::Range.new( * a, true )
          end
        end

        head_r = translate[ :head ]
        hot_r = translate[ :hotstring ]
        tail_r = translate[ :tail ]

        @_build_hs = -> do
          s[ hot_r ]
        end

        @_build_slug = -> do
         [ head_r, hot_r, tail_r ].reduce "" do | m, x |
            if x
              m.concat s[ x ]
            end
            m
          end
        end
      end

      def hotstring
        @___hs ||= _ :@_build_hs
      end

      def slug
        @___slug ||= _ :@_build_slug
      end

      def _ ivar
        remove_instance_variable( ivar ).call
      end
    end

    EGADS_RX___ = /\G(?<head>[a-z-]+)?\[(?<hotstring>[a-z-]+)\](?<tail>[a-z-]+)?/

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

      attr_accessor :sout

      # -- fake sout & serr

      def init_sout_like_serr

        io = Fake_Writable_IO__.new
        io.on_puts = -> s do
          @_receive[ :sout_line_string, s ]
          NIL_
        end
        # etc ..
        @sout = io
        NIL_
      end

      def ___build_fake_serr

        @_receive = -> sym, ss do

          _begin_new_screen

          @_receive[ sym, ss ]
        end

        io = Fake_Writable_IO__.new

        io.on_puts = -> s do
          @_receive[ :serr_line_string, s ]
          NIL_
        end

        io.on_write = -> s do
          @_receive[ :serr_write, s ]
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
          x  # should be fine as-is per #thread-two
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
            @_screens.last._close_screen
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

          screen.__accept sym, s
          NIL_
        end

        if @_do_debug
          dbg = @_debug_IO
          p0 = p
          p = -> sym, s do
            if :serr_line_string != sym
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

        io = remove_instance_variable :@sout
        io.close_fake_IO

        # assume always at least one screen

        if remove_instance_variable( :@_did_get_to_end )

          _x = remove_instance_variable :@_end_result
          end_result_wv = Callback_::Known_Known[ _x ]

        else

          @_screens.last._close_screen
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
