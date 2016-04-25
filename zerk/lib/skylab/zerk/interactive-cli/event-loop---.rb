module Skylab::Zerk

  class InteractiveCLI

    class Event_Loop___  # :[#002].

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

      @__main_view_controller = view_maker

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

      _top_ACS = @_build_top.call  # #cold-model, so do not pass @UI_event_handler

      x = @_view_maker_maker.custom_tree
      if x
        _ccv = Here_::Load_Ticket_::Compound_Custom_View.new x
      end

      @top_frame = _build_compound_adapter NOTHING_, _ccv, _top_ACS

      NIL_
    end

    # --

    def push_stack_frame_for lt

      send PUSH_FOR___.fetch( lt.four_category_symbol ), lt
      NIL_
    end

    PUSH_FOR___ = {
      # compound: __push_stack_frame_for_compound  # when covered
      entitesque: :_push_stack_frame_for_atomesque,
      operation: :__push_stack_frame_for_operation,
      primitivesque: :_push_stack_frame_for_atomesque,
    }

    # ~

    def __push_stack_frame_for_compound lt

      if lt.is_known_known
        self._K
      end

      # (we may have to do better event wiring than the below eventually..)

      acs = lt.association.component_model.interpret_compound_component(
        IDENTITY_ )

      if acs
        _ccv = lt.compound_custom_view
        @top_frame = _build_compound_adapter @top_frame, _ccv, acs
      end

      NIL_
    end

    def _build_compound_adapter below_frame, ccv, acs

      Here_::Compound_Frame___.new below_frame, ccv, acs, self
    end

    def __push_stack_frame_for_operation lt

      @top_frame = Here_::Operation_Frame___.new @top_frame, lt, self
      NIL_
    end

    def _push_stack_frame_for_atomesque lt

      @top_frame = Here_::Atomesque_Frame_.new @top_frame, lt, self
      NIL_
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
