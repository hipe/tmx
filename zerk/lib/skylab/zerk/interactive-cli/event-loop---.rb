module Skylab::Zerk

  class InteractiveCLI

    class Event_Loop___

      # (also services needed by many ancillaries)

      # <-

    def initialize vmm, rsx, & build_top
      @_build_top = build_top
      @_resources = rsx
      @_view_maker_maker = vmm
    end

    def run

      ___init_stack

      rsx = @_resources

      view_maker = @_view_maker_maker.make_view_maker__ self, rsx

      @_running = true
      @_serr = rsx.serr
      sin = rsx.sin

      begin

        @_do_redo = false

        view_maker.express

        if @_do_redo
          redo
        end

        s = nil

        begin
          s = sin.gets
        rescue ::Interrupt
        end

        if s
          __process_mutable_string_input s
        else
          # classify as "interrupt" all such cases :#thread-two
          __process_interrupt
        end
      end while @_running

      @_exitstatus
    end

    # -- building adapters & related

    def ___init_stack

      Require_ACS_[]

      @UI_event_handler = -> * i_a, & ev_p do
        receive_uncategorized_emission i_a, & ev_p
        UNRELIABLE_
      end

      @line_yielder = @_resources.line_yielder
      @serr = @_resources.serr
      @sout = @_resources.sout

      top_ACS = @_build_top.call  # #cold-model, so do not pass @UI_event_handler

      # --
      # for both of the following "conduits" (filesystem and system): IFF one
      # was set then assume the top ACS has such a writer (otherwise don't).

      kn = @_resources.filesystem_conduit_known_known
      if kn
        top_ACS.filesystem_knownness = kn
      end

      kn = @_resources.system_conduit_known_known
      if kn
        top_ACS.system_conduit_knownness = kn
      end

      # --

      a_p = @_view_maker_maker.custom_tree_array_proc__
      if a_p
        _load_ticket = Here_::Load_Ticket_::Root.via_array_proc a_p
      end

      @top_frame = _build_compound_adapter top_ACS, _load_ticket

      NIL_
    end

    # --

    def push_stack_frame_for lt

      send PUSH_FOR___.fetch( lt.four_category_symbol ), lt
      NIL_
    end

    PUSH_FOR___ = {
      compound: :__push_stack_frame_for_compound,
      entitesque: :_push_stack_frame_for_atomesque,
      operation: :__push_stack_frame_for_operation,
      primitivesque: :_push_stack_frame_for_atomesque,
    }

    # ~

    def __push_stack_frame_for_compound lt

      # we want the root frame and non-root compound frames to share as much
      # of the same code as we can. with the root frame, the ACS is a given
      # (it comes from the "outside") but here it is not..

      acs = ___attempt_to_touch_ACS_for lt

      if acs
        @top_frame = _build_compound_adapter @top_frame, acs, lt
      end

      NIL_
    end

    def ___attempt_to_touch_ACS_for lt

      _asc = lt.node_ticket.association
      _rw = @top_frame.reader_writer

      ACS_::Interpretation::Touch[ _asc, _rw ].value_x  # result is ACS itself
    end

    def _build_compound_adapter below_frame=nil, acs, lt

      Here_::Compound_Frame___.new below_frame, acs, lt, self
    end

    def __push_stack_frame_for_operation lt

      @top_frame = Here_::Operation_Frame___.new @top_frame, lt, self
      NIL_
    end

    def _push_stack_frame_for_atomesque lt

      @top_frame = Here_::Atomesque_Frame_.new @top_frame, lt, self
      NIL_
    end

    def push_whatever_this_is_to_the_stack x  # you can really wreck things [sa]
      @top_frame = x ; nil
    end

    # -- event handling

    def __process_interrupt

      p = @top_frame.interruption_handler
      if p
        p[]
      else
        self._COVER_ME
        _clean_exit
      end
      NIL_
    end

    def __process_mutable_string_input s

      @top_frame.process_mutable_string_input s

      NIL_
    end

    def receive_uncategorized_emission i_a, & ev_p

      @_resources.receive_uncategorized_emission i_a, & ev_p  # shh..
      UNRELIABLE_
    end

    # -- for ancillaries

    def loop_again
      @_do_redo = true ; nil
    end

    def pop_me_off_of_the_stack guy

      if @top_frame.object_id != guy.object_id
        self._COVER_ME
      end

      below = @top_frame.below_frame
      if below
        @top_frame = below
      else
        remove_instance_variable :@top_frame
        _clean_exit
      end
      NIL_
    end

    def _clean_exit

      @_serr.puts "goodbye."
      @_exitstatus = SUCCESS_EXITSTATUS
      @_running = false
      NIL_
    end

    # ->

      def to_root_frame  # [sa]
        x = @top_frame
        begin
          x_ = x.below_frame
          x_ or break
          x = x_
          redo
        end while nil
        x
      end

      def penultimate_frame
        @top_frame.below_frame
      end

      attr_reader(
        :line_yielder,
        :serr,
        :sout,
        :top_frame,
        :UI_event_handler,
      )
    end
  end
end
