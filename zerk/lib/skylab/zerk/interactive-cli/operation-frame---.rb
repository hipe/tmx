module Skylab::Zerk

  class InteractiveCLI

    class Operation_Frame___

      # ROUGH SKETCH

      def initialize below_frame, lt, el

        @below_frame = below_frame
        @event_loop = el
        @load_ticket = lt
        @serr = el.serr
        @UI_event_handler = el.UI_event_handler
      end

      def begin_UI_frame
        NIL_
      end

      def end_UI_frame
        NIL_
      end

      def express_operation_frame__ mvc

        _pp = __build_handler_builder

        _fo = __build_formal_operation

        _pvs = ACS_::Parameter::ValueSource_for_ArgumentStream.the_empty_value_source

        o = Home_::Invocation_::Procure_bound_call.begin_ _pvs, _fo, & _pp

        # ..

        bc = o.execute
        if bc
          __execute_this_or_bust bc, mvc
        else
          # (reasoning for the failure should have been emitted.)
          NOTHING_  # (hi.)
        end

        __finish
      end

      def __execute_this_or_bust bc, mvc

        # no matter what, we must pop this current (operation) frame off the
        # stack to end on whatever the lower one is (a compound frame).

        # we're gonna wanna know if an error was triggered because otherwise
        # we will take the result as meaningful whatever it is..
        # ya know what, we'll just ignore that thought for now..

        _x = bc.receiver.send bc.method_name, * bc.args, & bc.block

        _pxy = CLI_Proxy___.new mvc

        o = Home_::NonInteractiveCLI::Express_Result___.new _x, _pxy

        o.puts = -> s do
          @serr.puts s
        end

        o.init_exitstatus = -> _ do  # MONADIC_EMPTINESS_
          NOTHING_
        end

        o.execute

        NIL_
      end

      def __build_formal_operation

        # to build one, you need the full stack (because scope stack)

        _p = @load_ticket.node_ticket.proc_to_build_formal_operation
        _ss = Build_frame_stack_as_array_[ self ]
        _p[ _ss ]
      end

      Reference__ = ::Struct.new :value_x

      def __build_handler_builder

        oes_p = @UI_event_handler

        -> _ do
          oes_p
        end
      end

      def __finish
        @event_loop.pop_me_off_of_the_stack self
        @event_loop.loop_again
        NIL_
      end

      def name
        @load_ticket.name
      end

      attr_reader(
        :below_frame,
      )

      def four_category_symbol
        :operation
      end

      # ==

      class CLI_Proxy___

        def initialize mvc
          @MVC = mvc  # main view controller ("frame view controller")
        end

        def expression_agent
          @MVC.expression_agent_for_niCLI_library__
        end
      end

      # ==
    end
  end
end
# #history: replaces old "entitesque" counterpart in spirit (deleted here)
