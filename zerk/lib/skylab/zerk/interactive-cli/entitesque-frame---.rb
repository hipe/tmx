module Skylab::Zerk

  class InteractiveCLI

  class Entitesque_Frame___  # (built in 1 place by event loop)

    # #todo - needs full rewrite..

    # *very* experimental - guaranteed to change..
    #
    #   • wrap a "remote call" whose successful result is an object stream
    #   • implement adaptation to any custom view controller
    #   • stateful. the full state machine is depicted at [#010]

    def initialize lt, mvc, event_loop

      @event_loop = event_loop
      @_express = :__express_from_initial_state
      @load_ticket = lt
      @main_view_controller = mvc
      @_remote_callable = nil
    end

    # --

    def express_entitesque_frame__
      send @_express
    end

    def begin_UI_frame
      o = @_remote_callable
      if o
        o.begin_UI_frame
      end
      NIL_
    end

    def end_UI_frame
      o = @_remote_callable
      if o
        o.end_UI_frame
      end
      NIL_
    end

    def process_mutable_string_input s  # (if no `redo`, you get this)

      if @_remote_callable
        _ = @_remote_callable.process_mutable_string_input s
        _  # #todo
      else
        __process_mutable_string_via_component_model s
      end
    end

    def handler_for sym, *_
      @_remote_callable.handler_for( sym, *_ )
    end

    # --

    def __process_mutable_string_via_component_model s

      s.chomp!

      below = @event_loop.stack_penultimate

      _st = Callback_::Polymorphic_Stream.via s
      _asc = @load_ticket.association
      _ACS = below.ACS
      _pp = -> _ do  # ??
        @_call_oes_p
      end

      qk = ACS_::Interpretation::Build_value[ _st, _asc, _ACS, & _pp ]
      if qk

        below.accept_new_component_value__ qk

        # now that you have changed the state of the below compound,
        # hopefully it will look different and new paths are available

        @event_loop.pop_me_off_of_the_stack self

        NIL_

      else
        # you failed to process the input. just prompt again.
        NIL_
      end
    end

    # --

    def __express_from_initial_state

      @_last_error = nil

      @_call_oes_p = -> * i_a, & ev_p do
        if :error == i_a.first
          @_last_error = i_a.last
        end
        @event_loop.UI_event_handler[ * i_a, & ev_p ]
      end

      kn = @load_ticket.to_knownness__

      if kn.is_effectively_known

        __express_from_initial_state_when_component_value_is_known kn
      else
        __express_from_initial_state_when_component_value_is_unknown
      end
    end

    # --

    def __express_from_initial_state_when_component_value_is_unknown

      # (prompt like you are a primitive..)

      @main_view_controller.primitive_frame.call @event_loop.line_yielder
        # (imagine `express_primitive_frame_into_`)

      NIL_
    end

    def button_frame
      NOTHING_  # when you look like a primitivesque frame, offer this
    end

    def is_listy
      false  # same as above
    end

    def name
      @load_ticket.name
    end

    # --

    def __express_from_initial_state_when_component_value_is_known kn

      _st = Callback_::Polymorphic_Stream.the_empty_polymorphic_stream

      bc = kn.value_x.interpret_component( _st ) { |_| oes_p }

      if bc
        st = bc.receiver.send bc.method_name, * bc.args, & bc.block
        if st
          __call_and_change_state_when_object_stream st
        else
          __express_contextualization_of_remote_call_failure last_error
          _close
        end
      else
        self._COVER_ME_falseish_result_from_buttonesque
      end
    end

    def __express_contextualization_of_remote_call_failure last_error_sym

      _ = last_error_sym.id2name.gsub UNDERSCORE_, SPACE_

      @main_view_controller.serr.puts(
        "couldn't execute #{ @load_ticket.name.as_slug }#{
         } because of the above (\"#{ _ }\")" )

      NIL_
    end

    def __call_and_change_state_when_object_stream st

      @_object_stream = st
      cust_p = @load_ticket.custom_view_controller_proc
      if cust_p
        callable = cust_p[ @_object_stream, @main_view_controller, self ]
        if callable
          @_remote_callable = callable
          @_express = :___from_streamful_with_custom_view_state
          call
        else
          _close
        end
      else
        __from_streamful_with_default_view_state
      end
      NIL_
    end

    def ___from_streamful_with_custom_view_state

      _ignored = @_remote_callable.call
      NIL_
    end

    def __from_streamful_with_default_view_state  # (momentary)

      # the default expressive behavior is to flush the whole stream now.

      o = Remote_CLI_lib_[]::Express_Mixed.new
      o.expression_agent = @main_view_controller.expression_agent
      o.mixed_non_primitive_value = @_object_stream
      rsx = @event_loop
      o.serr = rsx.serr
      o.sout = rsx.sout
      _exitstatus = o.execute
      _close
      NIL_  # because you're on your own here
    end

    def _close

      # (leave `@_remote_callable` because it still gets the
      #  "end UI frame" signal)

      remove_instance_variable :@_express
      o = @event_loop
      o.pop_me_off_of_the_stack self
      o.loop_again_
      NIL_
    end

    # --

    attr_reader(
      :event_loop,  # custom views want this, like in [sa]
    )

    def shape_symbol
      :entitesque
    end
  end

  end
end
