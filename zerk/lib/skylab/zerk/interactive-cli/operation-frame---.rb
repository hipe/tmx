module Skylab::Zerk

  class InteractiveCLI

    class Operation_Frame___

      # ROUGH SKETCH

      def initialize lt, client
        @load_ticket = lt
        @_ = client
      end

      def begin_UI_frame
        NIL_
      end

      def end_UI_frame
        NIL_
      end

      def express_operation_frame__

        _pp = __build_handler_builder

        _fo = __build_formal_operation

        _pvs = ACS_::Parameter::ValueSource_for_ArgumentStream.the_empty_value_source

        o = Home_::Invocation_::Procure_bound_call.begin_ _pvs, _fo, & _pp

        # ..

        bc = o.execute
        if bc
          __execute_this_or_bust bc
        else
          # (reasoning for the failure should have been emitted.)
          NOTHING_  # (hi.)
        end

        __finish
      end

      def __execute_this_or_bust bc

        # no matter what, we must pop this current (operation) frame off the
        # stack and return to whatever the lower one is (a compound frame).

        # we're gonna wanna know if an error was triggered because otherwise
        # we will take the result as meaningful whatever it is..
        # ya know what, we'll just ignore that thought for now..

        _x = bc.receiver.send bc.method_name, * bc.args, & bc.block

        o = Home_::NonInteractiveCLI::Express_Result___.new _x, @_

        o.puts = -> s do
          @_.serr.puts s
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

        ss = @_.stack_as_array__

        _p[ ss ]
      end

      def __build_handler_builder

        oes_p = @_.UI_event_handler

        -> _ do
          oes_p
        end
      end

      def __finish
        @_.pop_me_off_of_the_stack self
        @_.loop_again
        NIL_
      end

      def name
        @load_ticket.name
      end

      def four_category_symbol
        :operation
      end
    end
  end
end
# #history: replaces old "entitesque" counterpart in spirit (deleted here)
