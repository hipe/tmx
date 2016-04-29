module Skylab::Zerk

  class InteractiveCLI

    class Operation_Item_Liner___ < Callback_::Actor::Dyadic  # references reference [#038]

      def initialize lt, _
        @load_ticket = lt
        @_ = _
      end

      def execute

        # egads - build the entire whootenany just to dootenany

        found = __try_description_proc_of_formal_operation
        found ||= __try_through_implementation
        if found
          __N_lines
        else
          EMPTY_A_  # result in this or else the item gets no listing at all
        end
      end

      def __N_lines

        o = Home_.lib_.basic::String::N_Lines.session
        o.description_proc = @__description_proc
        o.expression_agent = @_.expression_agent
        o.number_of_lines = NUMBER_OF_LINES_PER_ITEM_
        o.execute
      end

      def __try_description_proc_of_formal_operation

        @_fo = @_.compound_frame.build_formal_operation_via_node_ticket_ @load_ticket.node_ticket
        _maybe @_fo.description_proc
      end

      def __try_through_implementation
        _maybe @_fo.description_proc_thru_implementation
      end

      def _maybe d_p
        if d_p
          @__description_proc = d_p ; ACHIEVED_
        end
      end
    end
  end
end
