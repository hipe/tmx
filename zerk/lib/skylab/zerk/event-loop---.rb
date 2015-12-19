module Skylab::Zerk

  class Event_Loop___  # :[#002].

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

        view_maker.express
        s = nil

        begin
          s = sin.gets
        rescue ::Interrupt
        end

        if s
          __process_mutable_string_input s
        else
          # (per #detail-two, we classify as "interrupt" all such cases)
          __process_interrupt
        end
      end while @_running

      @_exitstatus
    end

    # -- building adapters & related

    def ___init_stack

      Require_ACS_[]

      _top_oes_p = -> * i_a, & ev_p do  # :[#]#detail-one

        receive_uncategorized_emission i_a, & ev_p
        UNRELIABLE_
      end

      rsx = Frame_Resources___.new(
        @_resources.line_yielder,
        @_resources.serr,
        self,
      )

      @_frame_resources = rsx

      _top = @_build_top.call rsx, & _top_oes_p

      @_stack = [ Home_::Compound_Adapter___.new( _top, rsx ) ]

      NIL_
    end

    def push_stack_frame_for qkn

      if qkn.is_known_known
        self._FUN_TIMES
      else
        _ = qkn.association.model_classifications.category_symbol
        send :"__push_stack_frame_for_new__#{ _ }__", qkn
      end
      NIL_
    end

    def __push_stack_frame_for_new__primitivesque__ qkn

      _new = Home_::Primitivesque_Adapter___.new( qkn, @_frame_resources )

      @_stack.push _new

      NIL_
    end

    Frame_Resources___ = ::Struct.new(
      :line_yielder,
      :serr,
      :view_controller,
    )

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
  end
end
