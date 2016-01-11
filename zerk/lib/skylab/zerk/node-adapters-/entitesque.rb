module Skylab::Zerk

  class Node_Adapters_::Entitesque  # (built in 1 place by event loop)

    # *very* experimental - guaranteed to change..
    #
    #   • wrap a "remote call" whose successful result is an object stream
    #   • implement adaptation to any custom view controller
    #   • stateful. the full state machine is depicted at [#010]

    def initialize lt, fvc, event_loop

      @event_loop = event_loop
      @load_ticket = lt
      @main_view_controller = fvc
      @_remote_callable = nil
      @_state_method_name = :__from_initial_state
    end

    # --

    def call
      send @_state_method_name
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

      _ = @_remote_callable.process_mutable_string_input s
      _
    end

    def handler_for sym, *_
      @_remote_callable.handler_for( sym, *_ )
    end

    # --

    def __from_initial_state

      last_error = nil
      oes_p = -> * i_a, & ev_p do
        if :error == i_a.first
          last_error = i_a.last
        end
        @event_loop.UI_event_handler[ * i_a, & ev_p ]
      end

      _st = Callback_::Polymorphic_Stream.the_empty_polymorphic_stream

      bc = @load_ticket.value_x.interpret_component( _st ) { |_| oes_p }

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
          @_state_method_name = :___from_streamful_with_custom_view_state
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

      o = Home_.lib_.brazen::CLI_Support::Express_Mixed.new
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

      remove_instance_variable :@_state_method_name
      o = @event_loop
      o.pop_me_off_of_the_stack self
      o.redo
      NIL_
    end

    # --

    attr_reader(
      :event_loop,  # custom views want this, like in [sa]
    )

    def shape_symbol
      :entitesque
    end

    UNDERSCORE_ = '_'
  end
end
