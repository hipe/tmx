module Skylab::Zerk

  class InteractiveCLI::Event_Loop___  # :[#002].

    def initialize vmm, rsx, & build_top

      @_build_top = build_top
      @_resources = rsx
      @_view_maker_maker = vmm
    end

    def run

      ___init_stack

      rsx = @_resources

      view_maker = @_view_maker_maker.make_view_maker(
        @_stack, rsx )

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

      top_oes_p = -> * i_a, & ev_p do  # this is this. :#thread-one

        receive_uncategorized_emission i_a, & ev_p
        UNRELIABLE_
      end

      @line_yielder = @_resources.line_yielder
      @serr = @_resources.serr
      @sout = @_resources.sout
      @UI_event_handler = top_oes_p

      _top_ACS = @_build_top.call self, & top_oes_p

      x = @_view_maker_maker.custom_tree
      if x
        _ccv = Home_::Load_Ticket_::Compound_Custom_View.new x
      end

      @_stack = [ _build_compound_adapter( _top_ACS, _ccv ) ]

      NIL_
    end

    # -- parameters for lower-level modules (used to be "frame resources")

    def view_controller
      self
    end

    attr_reader(
      :line_yielder,
      :serr,
      :sout,
      :UI_event_handler,
    )

    # --

    def push_stack_frame_for lt

      send :"__push_stack_frame_for_new__#{ lt.category_symbol }__", lt
      NIL_
    end

    def __push_stack_frame_for_new__primitivesque__ lt

      _new = Home_::Node_Adapters_::Primitivesque.new lt, self
      @_stack.push _new
      NIL_
    end

    def __push_stack_frame_for_new__entitesque__ lt

      _new = Home_::Node_Adapters_::Entitesque.new lt, self
      @_stack.push _new
      NIL_
    end

    def __push_stack_frame_for_new__compound__ lt

      if lt.is_known_known
        self._K
      end

      # (we may have to do better event wiring than the below eventually..)

      acs = lt.association.component_model.interpret_compound_component(
        IDENTITY_ )

      if acs
        _ccv = lt.compound_custom_view
        _ = _build_compound_adapter acs, _ccv
        @_stack.push _
      end

      NIL_
    end

    def _build_compound_adapter acs, ccv

      Home_::Node_Adapters_::Compound.new acs, ccv, self
    end

    # -- event handling

    def __process_interrupt

      p = @_stack.last.handler_for :interrupt
      if p
        p[]
      else
        self._COVER_ME
        _clean_exit
      end
      NIL_
    end

    def __process_mutable_string_input s

      @_stack.last.process_mutable_string_input s

      NIL_
    end

    def receive_uncategorized_emission i_a, & ev_p

      @_resources.receive_uncategorized_emission i_a, & ev_p  # shh..
      UNRELIABLE_
    end

    # -- API as view controller

    def redo
      @_do_redo = true ; nil
    end

    def pop_me_off_of_the_stack guy

      top = @_stack.last

      if top.object_id != guy.object_id
        self._COVER_ME
      end

      @_stack.pop

      if @_stack.length.zero?
        _clean_exit
      end
      NIL_
    end

    def stack_top
      @_stack.last
    end

    def stack_penultimate
      @_stack[ -2 ]
    end

    def _clean_exit

      @_serr.puts "goodbye."
      @_exitstatus = SUCCESS_EXITSTATUS
      @_running = false
      NIL_
    end

    IDENTITY_ = -> x { x }
  end
end
