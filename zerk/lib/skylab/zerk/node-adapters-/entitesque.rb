module Skylab::Zerk

  class Node_Adapters_::Entitesque  # (built in 1 place by event loop)

    # we know this is shortsighted but for now dootily-hah yeehah:
    #
    #   • this doesn't interact with view-controllers like the others because
    #     its behavior (appearance) is almost fully external (implemented by
    #     the client code).
    #
    #   • for now, we assume the entityesque is buttonesque AND that its
    #     successful result is a stream (of something).

    def initialize lt, event_loop

      @_load_ticket = lt
      @_event_loop = event_loop
    end

    def begin_UI_frame
      NIL_
    end

    def call frame_vc

      _node = @_load_ticket.value_x
      _st = Callback_::Polymorphic_Stream.the_empty_polymorphic_stream

      last_error = nil
      oes_p = -> * i_a, & ev_p do
        if :error == i_a.first
          last_error = i_a.last
        end
        @_event_loop.UI_event_handler[ * i_a, & ev_p ]
      end

      _pp = -> _ do
        oes_p
      end

      bc = _node.interpret_component _st, & _pp
      if bc
        st = bc.receiver.send bc.method_name, * bc.args, & bc.block
        if st
          __via_trueish_result st, frame_vc
        else
          ___when_stream_production_failed last_error, frame_vc
        end
      else
        self._COVER_ME_falseish_result_from_buttonesque
      end
    end

    def ___when_stream_production_failed last_error_sym, frame_vc

      _ = last_error_sym.id2name.gsub UNDERSCORE_, SPACE_

      frame_vc.serr.puts "couldn't execute #{ @_load_ticket.name.as_slug }#{
        } because of the above (\"#{ _ }\")"

      _common_finish
    end

    def __via_trueish_result st, frame_vc

      p = @_load_ticket.custom_view_controller_proc
      if p
        x = p[ st, frame_vc, @_event_loop ]
        if x
          _ignored = x.call
          _common_finish
        end
      else
        ___express_as_stream st, frame_vc
      end
      NIL_
    end

    def ___express_as_stream st, frame_vc

      o = Home_.lib_.brazen::CLI_Support::Express_Mixed.new
      o.expression_agent = frame_vc.expression_agent
      o.mixed_non_primitive_value = st
      rsx = @_event_loop
      o.serr = rsx.serr
      o.sout = rsx.sout
      _exitstatus = o.execute
      _common_finish
      NIL_  # because you're on your own here
    end

    def _common_finish

      o = @_event_loop
      o.pop_me_off_of_the_stack self
      o.redo
      NIL_
    end

    def end_UI_frame
      NIL_
    end

    def shape_symbol
      :entitesque
    end

    UNDERSCORE_ = '_'
  end
end
