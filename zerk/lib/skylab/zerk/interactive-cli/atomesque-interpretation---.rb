module Skylab::Zerk

  class InteractiveCLI

    class Atomesque_Interpretation___

      # there is no result value, only behavior.

      def initialize mutable_s, frame
        @_ = frame  # ivar name explained in #[#bs-032]
        @_mutable_s = mutable_s
      end

      def execute

        # (no result value only behavior so procede/cease not success/failure)

        on = __resolve_any_stream
        on &&= __via_stream
        on && __process_new_component_value
        NIL_
      end

      def __process_new_component_value

        # the topmost frame is the one for the atomesque. write its
        # new value into the compound node which is the frame below it..

        _qk = remove_instance_variable :@__qk
        _rw = @_event_loop.stack_penultimate.reader_writer

        p = ACS_::Interpretation::Accept_component_change.call _qk, _rw

          # (we could pass a block for building a linked list of context)

        @_model_oes_p.call :info, :set_leaf_component do

          # we almost could do without this message ('set foo to "BAR"')
          # but for now we think it's good to have the feedback. and #grease

          p[]
        end

        @_event_loop.pop_me_off_of_the_stack @_

        NIL_
      end

      def __via_stream

        @_event_loop = @_.event_loop
        @_model_oes_p = @_.model_emission_handler__

        _pp = -> _ do
          @_model_oes_p
        end

        _ACS = @_event_loop.stack_penultimate.ACS
        _asc = @_.load_ticket.association
        _st = remove_instance_variable :@__stream

        qk = ACS_::Interpretation::Build_value[ _st, _asc, _ACS, & _pp ]
        if qk
          @__qk = qk
          PROCEDE_
        else
          # the model should have emitted something about the invalidity. if
          # we do nothing more, we will re-prompt for the same thing again
          DONE_ # which is what we want.
        end
      end

      def __resolve_any_stream

        # when `gets` stops blocking, assume the "input buffer" ends with a
        # newline character. assume this is never meaningful and chomp it
        # always. any *leading* whitespace chars, however, might have meaning
        # according (autonomously) to the component model so we leave them
        # intact (i.e in contrast to processing buttonesque input, we do not
        # `strip`).

        s = remove_instance_variable :@_mutable_s
        s.chomp!

        # for now we don't care if there was one and if so what the old value
        # was; but if you did, that processing would happen here.
        # what we *do* care about is if this is processing lists as lists.

        if @_.is_listy
          a = Here_::List_Interpretation_Adapter___[ s, & @_.UI_event_handler ]
          if a
            st = Home_.lib_.fields::Argument_stream_via_value[ a ]
          end  # else emitted
        else
          st = Home_.lib_.fields::Argument_stream_via_value[ s ]
        end

        if st
          @__stream = st
          PROCEDE_
        else
          # (probably this means converting the input to a list failed.)
          DONE_
        end
      end

      DONE_ = false
      PROCEDE_ = true
    end
  end
end
# #history: outgrew "atomesque frame"
