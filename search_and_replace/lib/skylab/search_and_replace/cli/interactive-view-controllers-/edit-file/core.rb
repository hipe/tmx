module Skylab::SearchAndReplace

  module CLI

    class Interactive_View_Controllers_::Edit_File

      # encompasses all the behavior that UI does that API does not,
      # namely, the *interative* parts of search & replace (and all
      # the UI & UI state that goes along with that).

      def initialize st, _
        @_m = :__first_call
        @object_stream = st
        @services = _
      end

      def call
        send @_m
        NIL_
      end

      def __first_call
        if @object_stream
          __init_ivars
          @__first_item = @object_stream.gets
          if @__first_item
            __really_boogie
            NIL_
          else
            @_line_yielder << "(no matches.)"
            @_event_loop.pop_me_off_of_the_stack @_operation_frame
            @_event_loop.loop_again
          end
        else
          NOTHING_
        end
      end

      # -- buttonesque visibility & reactions

      # ~ macros

      def __all_remaining  # assume has next file

        self._COVER_ME_might_be_OK

        o = Home_::Magnetics_::All_Remaining_via_Parameters.new( & @UI_event_handler )
        o.expression_agent = @__expression_agent
        o.file_UOW = @_file_UOW
        o.gets_one_next_file = -> do
          _move_to_next_file
          @_file_UOW
        end
        o.serr = @_serr
        _ok = o.execute  # ignore the t/f of whether it succeeded
        _close_frame
        NIL_
      end

      def __all_remaining_in_file  # assume has next match

        _ok = @_file_UOW.engage_all_remaining_in_file  # (t/f result is ignored)
        __express_matches_only
        NIL_
      end

      # ~ file navigation & write support

      def __do_display_write_file_button  # ..

        # display this buttonesque IFF we are on the last
        # file and one or more matches are engaged.

        ! ( @_file_UOW.has_next_file || @_file_UOW.engaged_count.zero? )
      end

      def __has_next_file
        @_file_UOW.has_next_file
      end

      def __next_file  # assume above
        _write_and_express_current_file
        _move_to_next_file
        NIL_
      end

      def __write_final_file  # assume no next file
        _write_and_express_current_file
        _close_frame
        NIL_
      end

      def _close_frame

        # one-time hack so that you can review last summary and stay in frame
        remove_instance_variable :@object_stream
        @_file_UOW = Home_::Magnetics_::File_Unit_of_Work.the_empty_unit_of_work
        @_m = :___say_job_finished
        NIL_
      end

      def ___say_job_finished
        @_line_yielder << "(job finished. Ctrl-C to jump out of frame.)"
        NIL_
      end

      def _write_and_express_current_file

        _ok = @_file_UOW.maybe_write
        _ok && __express_current_file_after_write
        NIL_
      end

      def _move_to_next_file

        _sess = @_file_UOW.next_file_session
        _sess_ = @object_stream.gets
        @_file_UOW = @_file_UOW_prototype.via_two _sess, _sess_
        NIL_
      end

      def interruption_handler  # based off of [#ze-045]

        -> do
          @_event_loop.pop_me_off_of_the_stack self

          # (what is now on top is the operation frame.
          # get that off too or we'll loop right back into it (somehow))

          @_event_loop.pop_me_off_of_the_stack @_event_loop.top_frame
          NIL_
        end
      end

      # ~ expression near matches & write

      def __express_current_file_after_write  # no need to express path

        _ = @_file_UOW.say_wrote_under @_expression_agent
        @_line_yielder << _
        NIL_
      end

      def __express_matches_only

        uow = @_file_UOW
        _eng_d = uow.engaged_count
        mat_d = uow.match_count

        @UI_event_handler.call :info, :expression, :matches_summary do |y|
          _ = plural_noun mat_d, 'match'
          y << "#{ _eng_d } of #{ mat_d } #{ _ } engaged."
        end
        NIL_
      end

      # ~ match navigation & manipulation

      def __has_previous_match
        @_file_UOW.has_previous_match
      end

      def __previous_match  # assume above
        @_file_UOW.move_to_previous_match
        _reinit_styled_expresser
        NIL_
      end

      def __has_current_match
        @_file_UOW.has_current_match
      end

      def __toggle_current_match_is_engaged  # assume above
        @_file_UOW.toggle_current_match_is_engaged
      end

      def __has_next_match
        @_file_UOW.has_next_match
      end

      def __next_match  # assume above
        @_file_UOW.move_to_next_match
        _reinit_styled_expresser
        NIL_
      end

      # -- boogey & expression

      def __init_ivars

        _ = remove_instance_variable :@services
        @_event_loop = _.event_loop
        @_expression_agent = _.expression_agent
        @_line_yielder = _.line_yielder
        @_main_view_controller = _.main_view_controller
        @_operation_frame = _.operation_frame
        @_serr = _.serr
        @UI_event_handler = _.UI_event_handler

        NIL_
      end

      def __really_boogie

        __init_all_buttonesques
        __init_plain_expresser
        __init_file_UOW_prototype

        _ = remove_instance_variable :@__first_item
        __ = @object_stream.gets
        _reinit_entity_via_two_sessions _, __

        @_event_loop.push_whatever_this_is_to_the_stack self
        @_event_loop.loop_again
        @_m = :___main_call

        NIL_
      end

      def four_category_symbol
        :custom
      end

      def ___main_call
        _boundary
        @_main_view_controller.express_location_area
        ___express_body
        __express_buttonesques
        NIL_
      end

      def ___express_body

        if @_file_UOW.has_file
          if @_file_UOW.has_current_match
            ___express_body_normally
          else
            self._COVER_ME_no_current_match
          end
        else
          self._COVER_ME_no_current_file
        end
        NIL_
      end

      def ___express_body_normally  # assume current match

        uow = @_file_UOW

        _fileno = @_file_UOW_prototype.instance_count
        _eng = uow.replacement_is_engaged_of_current_match ? RE___ : RNE___
        _matchno = uow.ordinal_of_current_match
        _path = uow.path
        _y = @_line_yielder

        _boundary

        _y << "file #{ _fileno } match #{ _matchno }#{ _eng }: #{ _path }"

        _boundary

        _cm = uow.current_match_controller

        be_st, du_st, af_st = _cm.to_contexted_throughput_line_streams_(
          NUM_LINES_BEFORE__,
          NUM_LINES_AFTER__,
        )

        @_plain_expresser.call be_st
        @_styled_expresser.call du_st
        @_plain_expresser.call af_st

        _boundary

        NIL_
      end

      NUM_LINES_BEFORE__ = 2
      NUM_LINES_AFTER__ = 2
      RE___ = ' (replacement engaged)'
      RNE___ = ' (before)'

      def __express_buttonesques
        @_main_view_controller.express_buttonesques @_available_butz_a
        NIL_
      end

      def __init_plain_expresser

        pe = Here_::Line_Expresser__.new @_line_yielder

        pe.render_static = -> s do
          s
        end

        pe.render_match_when_replacement_engaged = -> _d, s do
          s
        end

        pe.render_match_when_replacement_not_engaged = -> _d, s do
          s
        end

        @_plain_expresser = pe ; nil
      end

      def _reinit_styled_expresser  # must rebuild whenever match changes!

        stylify = Home_.lib_.brazen::CLI_Support::Styling::Stylify

        se = Here_::Line_Expresser__.new @_line_yielder

        match_d = @_file_UOW.current_match_controller.match_index  # eew - ..

        se.render_static = -> s do
          s
        end

        se.render_match_when_replacement_engaged = -> d, s do
          if match_d == d
            stylify[ REPLACEMENT_STYLE__, s ]
          else
            s
          end
        end

        se.render_match_when_replacement_not_engaged = -> d, s do
          if match_d == d
            stylify[ ORIGINAL_STYLE__, s ]
          else
            s
          end
        end

        @_styled_expresser = se ; nil
      end

      ORIGINAL_STYLE__ = [ :strong, :green ]
      REPLACEMENT_STYLE__ = [ :strong, :blue ]

      # ~ expression support

      def _boundary
        @_main_view_controller.touch_boundary
        NIL_
      end

      # -- model

      def _reinit_entity_via_two_sessions sess, sess_

        @_file_UOW = @_file_UOW_prototype.via_two sess, sess_
        NIL_
      end

      def __init_file_UOW_prototype

        @_file_UOW_prototype = Home_::Magnetics_::File_Unit_of_Work.prototype(
          & @UI_event_handler )

        NIL_
      end

      # -- buttonesque constitution

      def __init_all_buttonesques

        butt = Buttonesque_view_controller__[]
        a = []

        # p r y n f a A

        a.push butt.new(
          :name_symbol, :prev_match,
          :is_available, method( :__has_previous_match ),
          :on_press, method( :__previous_match ),
        )

        a.push butt.new(
          :name_symbol_proc, -> do
            if @_file_UOW.replacement_is_engaged_of_current_match
              :revert_to_original
            else
              :yes
            end
          end,
          :is_available, method( :__has_current_match ),
          :on_press, method( :__toggle_current_match_is_engaged ),
        )

        has_next_match = method :__has_next_match

        a.push butt.new(
          :name_symbol, :next_match,
          :is_available, has_next_match,
          :on_press, method( :__next_match ),
        )

        has_next_file = method :__has_next_file

        a.push butt.new(
          :hotstring_delineation, %w( next- f ile ),
          :is_available, has_next_file,
          :on_press, method( :__next_file ),
        )

        a.push butt.new(
          :name_symbol, :write_file,
          :is_available, method( :__do_display_write_file_button ),
          :on_press, method( :__write_final_file ),
        )

        a.push butt.new(
          :name_symbol, :all_remaining_in_file,
          :is_available, has_next_match,
          :on_press, method( :__all_remaining_in_file ),
        )

        a.push butt.new(
          :hotstring_delineation, [ NIL_, 'A', 'll-remaining' ],
          :is_available, has_next_file,
          :on_press, method( :__all_remaining ),
        )

        @_all_butz_a = a
        NIL_
      end

      # -- boring hook-outs

      def below_frame  # used to grind state at end
        @_operation_frame
      end

      def end_UI_panel_expression
        NOTHING_
      end

      def begin_UI_panel_expression

        butz = Buttonesque_view_controller__[].begin_frame

        @_all_butz_a.each do |butt|
          if butt.button_is_available
            butz.add butt
          end
        end

        @_available_butz_a = butz.finish

        if @_file_UOW.has_current_match
          _reinit_styled_expresser
        end

        NIL_
      end

      def process_mutable_string_input s  # (partially duplicate "compound" n.a)

        s.strip!
        if s.length.zero?
          @_line_yielder << "(nothing entered.)"
        else
          butt = Buttonesque_view_controller__[].interpret s, self
          if butt
            _ = butt.on_press.call
            _  # ignored
          end
        end
        NIL_
      end

      def to_stream_for_resolving_buttonesque_selection  # for above
        Common_::Stream.via_nonsparse_array @_available_butz_a
      end

      attr_reader(
        :UI_event_handler,  # e.g unresolvable button
      )

      def handler_for sym, *_  # e.g interrupt
        if :interrupt == sym
          -> do
            _ = @_event_loop.pop_me_off_of_the_stack @_operation_frame
            NIL_
          end
        end
      end

      Buttonesque_view_controller__ = -> do
        Zerk_::InteractiveCLI::Buttonesque_ViewController
      end

      Here_ = self
    end
  end
end
