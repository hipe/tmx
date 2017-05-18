module Skylab::Zerk

  class InteractiveCLI

    class Operation_Frame___

      # ROUGH SKETCH

      def initialize below_frame, lt, el

        @below_frame = below_frame
        @event_loop = el
        @loadable_reference = lt
        @serr = el.serr
        @UI_event_handler = el.UI_event_handler
      end

      def begin_UI_panel_expression
        NIL_
      end

      def end_UI_panel_expression
        NIL_
      end

      def express_operation_frame__ mvc

        _pp = __build_handler_builder

        _fo = __build_formal_operation

        _pvs = ACS_::Parameter::ValueSource_for_ArgumentScanner.the_empty_value_source

        o = Home_::Invocation_::Procure_bound_call.begin_ _pvs, _fo, & _pp

        # ..

        bc = o.execute
        if bc
          __execute_this_or_bust bc, mvc
        else
          # (reasoning for the failure should have been emitted.)
          _finish
        end
      end

      def __execute_this_or_bust bc, mvc

        # no matter what, we must pop this current (operation) frame off the
        # stack to end on whatever the lower one is (a compound frame).

        # we're gonna wanna know if an error was triggered because otherwise
        # we will take the result as meaningful whatever it is..
        # ya know what, we'll just ignore that thought for now..

        x = bc.receiver.send bc.method_name, * bc.args, & bc.block

        p = @loadable_reference.custom_view_controller_proc__

        @main_view_controller = mvc

        if p
          __express_result_customly x, p
        else
          __express_result_commonly x
        end
      end

      def __express_result_customly x, p

        _ = Thing_Proxy___.new self  # could memoize ..

        @_custom_view_controller = p[ x, _ ]

        @_custom_view_controller.call

        NIL_
      end

      def __express_result_commonly x

        _pxy = CLI_Proxy___.new @main_view_controller

        o = Home_::CLI::ExpressResult.new x, _pxy

        o.puts = -> s do
          @serr.puts s
        end

        o.init_exitstatus = -> _ do  # MONADIC_EMPTINESS_
          NOTHING_
        end

        o.execute

        _finish
      end

      def __build_formal_operation

        # to build one, you need the full stack (because scope stack)

        _p = @loadable_reference.node_reference.proc_to_build_formal_operation
        _ss = Build_frame_stack_as_array_[ self ]
        _p[ _ss ]
      end

      Reference__ = ::Struct.new :value

      def __build_handler_builder

        oes_p = @UI_event_handler

        -> _ do
          oes_p
        end
      end

      def _finish

        # this gets called here but it does NOT get called when there is
        # a custom view controller. that must call the below (or not) itself.

        @event_loop.pop_me_off_of_the_stack self
        @event_loop.loop_again
        NIL_
      end

      def name
        @loadable_reference.name
      end

      attr_reader(
        :below_frame,
        :event_loop,  # #here
        :main_view_controller,
        :serr,  # #here
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
          @MVC.expression_agent_for_niCLI_library_
        end

        def stderr
          @MVC.serr
        end
      end

      # ==

      class Thing_Proxy___  # :#here

        def initialize _
          @_ = _
        end

        def event_loop
          @_.event_loop
        end

        def expression_agent
          @_.main_view_controller.expression_agent_for_niCLI_library_
        end

        def line_yielder
          @_.event_loop.line_yielder
        end

        def main_view_controller
          @_.main_view_controller
        end

        def operation_frame
          @_  # ONLY for poppping off the stack
        end

        def serr
          @_.serr
        end

        def UI_event_handler
          @_.event_loop.UI_event_handler
        end
      end
    end
  end
end
# #history: replaces old "entitesque" counterpart in spirit (deleted here)
