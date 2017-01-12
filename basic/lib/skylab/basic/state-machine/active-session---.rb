module Skylab::Basic

  class StateMachine

    class ActiveSession___ < SimpleModel_

      # things to remember about grammars here:
      #   - to be a formal transition target, the state must have a barrier to entry

      def initialize
        @downstream = nil
        @downstream_by = nil
        @listener = nil
        yield self
      end

      attr_writer(
        :box,
        :downstream,
        :downstream_by,
        :listener,
        :page_listener,
        :upstream,
      )

      def execute

        @downstream || reinit_downstream
        init_state
        @_user_matchdata = nil

        begin
          _keep_parsing = step
          # (having the variable as a symbol can be useful for debugging here.)
          _keep_parsing ? redo : break
        end while above

        remove_instance_variable :@_result
      end

      def init_state
        @state = @box.fetch :beginning
        NIL
      end

      # --

      def step
        if @state.has_handler
          __step_via_handler
        elsif @state.has_at_least_one_formal_transition
          step_via_find_transition
        else
          __fail_because_none_of_the_two
        end
      end

      def __step_via_handler
        _md = remove_instance_variable :@_user_matchdata
        o = Here_::HandlerInvocation_via_Session_.
          new( _md, @state, self ).execute
        if o.set_a_directive
          __step_when_directive o
        elsif o.had_a_trueish_result
          if @state.has_at_least_one_formal_transition
            __fail_because_result_and_formals
          else
            __step_via_handler_result o.trueish_result
          end
        elsif @state.has_at_least_one_formal_transition
          step_via_find_transition
        else
          __fail_because_none_of_the_three
        end
      end

      def __step_when_directive o
        send DIRECTIVES___.fetch( o.directive_symbol ), o
      end

      DIRECTIVES___ = {
        _end_: :__step_at_end,
        _end_when_paginated_: :__step_at_end_when_paginated,
        _turn_page_over_: :__step_at_turn_page_over,
      }

      def immediate_notification_for_turn_page_over__
        @page_listener.immediate_notification_for_turn_page_over
        NIL
      end

      def __step_at_turn_page_over o
        @page_listener.step_after_turn_page_over o
      end

      def __step_at_end_when_paginated o
        @page_listener.step_at_end o
      end

      def __step_at_end o
        if o.had_a_trueish_result
          _fail_because_end_and_result
        elsif @state.has_at_least_one_formal_transition
          fail_because_end_and_transitions
        else
          __do_end
        end
      end

      def __do_end
        @_result = release_downstream
        STOP_PARSING_
      end

      def __step_via_handler_result sym  # assume no directive, no transitions

        sta = @box.fetch sym
        if sta.has_barrier_to_entry
          md = sta._user_matchdata_via_upstream @upstream
          if md
            @_user_matchdata = md
            @state = sta
            sym
          else
            _ = Common_::Stream.via_item sta
            _whine_via_splay_stream _
          end
        else
          @state = sta
          sym
        end
      end

      def step_via_find_transition

        st = _to_possible_next_state_stream

        begin
          sta = st.gets
          sta || break

          md = sta._user_matchdata_via_upstream @upstream
          md ? break : redo
        end while above

        if sta
          @_user_matchdata = md
          @state = sta
          sta.name_symbol  # or KEEP_PARSING_
        else
          _whine_via_splay_stream _to_possible_next_state_stream
        end
      end

      def reinit_downstream
        p = @downstream_by
        @downstream = p ? p[] : []
        NIL
      end

      def release_downstream
        remove_instance_variable :@downstream
      end

      # -- whines

      def _whine_via_splay_stream st
        us = remove_instance_variable :@upstream
        same = -> do
          Here_::Events_::NoAvailableStateTransition.via us, st
        end
        if @listener
          @listener.call :error, :case, :no_available_state_transition do
            same[]
          end
          @_result = UNABLE_
          STOP_PARSING_
        else
          raise same[].to_exception
        end
      end

      # -- fails

      def fail_because_end_and_result
        _fail_because do |y|
          y << "{{ state }} handler invoked an `end` directive"
          y << "and also resulted in trueish - cannot do both."
        end
      end

      def fail_because_end_and_transitions
        _fail_because do |y|
          y << "{{ state }} handler invoked an `end` directive"
          y << "and also defines transitions - cannot do both."
        end
      end

      def __fail_because_none_of_the_three
        _fail_because do |y|
          y << "{{ state }} handler neither invoked a directive nor"
          y << "resulted in trueish, and state does not define transisions."
          y << "it must do one of these."
        end
      end

      def __fail_because_none_of_the_two
        _fail_because do |y|
          y << "{{ state }} does not define a handler nor transitions."
          y << "it must define one of these."
        end
      end


      def __fail_because_result_and_formals
        _fail_because do |y|
          y << "{{ state }} handler resulted in trueish ({{ result }})"
          y << "and state defines transitions - cannot do both."
        end
      end

      define_method :_fail_because, DEFINITION_FOR_THE_METHOD_CALLED_FAIL_BECAUSE_

      # -- read

      def _to_possible_next_state_stream
        sta = @state
        if sta.has_at_least_one_formal_transition
          h = @box.h_
          if sta.has_exactly_one_formal_transition
            Common_::Stream.via_item h.fetch sta.formal_transition_state_symbol
          else
            Stream_.call sta.formal_transition_symbol_array do |sym|
              h.fetch sym
            end
          end
        else
          Common_::Stream.the_empty_stream
        end
      end

      attr_reader(
        :downstream,
        :state,
      )

      # ==

      # ==
    end
  end
end
