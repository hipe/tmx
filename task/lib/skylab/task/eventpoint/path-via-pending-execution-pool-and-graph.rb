class Skylab::Task

  class Eventpoint::Path_via_PendingExecutionPool_and_Graph < Common_::MagneticBySimpleModel

    # exactly the [#004.A] algorithm. synopsis:

        # central thesis: start from the beginning node. at each current node
        # resolve exactly zero or one move that you can make. the ambiguity of
        # having multiple agents express a move (even the same one) triggers a
        # soft error and halts further execution. stop when either you reach
        # the target or you cannot make any more moves. if you did not reach
        # the goal (for any of the above reasons), you will have whined
        # appropritely and the result is false. else you were silent and
        # result is some kind of execution path structure.
    # -

      attr_writer(
        :graph,
        :listener,
        :pending_execution_pool,
      )

      def execute

        __index_all_formal_transitions

        @_ok = true

        until __current_state_is_ending_state
          _yes = __resolve_one_single_active_transition_for_this_step
          _yes && next
          @_ok || break
          _yes = __resolve_one_single_passive_transition_for_this_step
          _yes && next
          @_ok || break
          __whine_about_how_no_transition_was_found
          break
        end

        if @_ok
          __check_that_all_imperative_transitions_were_employed
        end

        @_ok && __flush_path
      end

      def __whine_about_how_no_transition_was_found
        @_ok = false
        Eventpoint::When_::NoTransitionFound[ self ]
      end

      def __check_that_all_imperative_transitions_were_employed
        h = remove_instance_variable :@_imperative_transition_pool
        if h.length.nonzero?
          @_ok = false
          self._COVER_ME__the_rest_as_it_was_done_in_the_past__
        end
        NIL  # falsify @_ok on failure
      end

      def __flush_path
        Path___.new remove_instance_variable( :@_path ).freeze
      end

      def __resolve_one_single_active_transition_for_this_step
        _same @active_formal_transitions_via_source
      end

      def __resolve_one_single_passive_transition_for_this_step
        _same @passive_formal_transitions_via_source
      end

      def _same formal_transitions_via_source

        d_a = formal_transitions_via_source[ @current_state_symbol ]
        if d_a
          if 1 == d_a.length
            __when_one_formal_transition d_a.fetch 0
          else
            __when_ambiguous d_a
          end
        end
      end

      def __when_ambiguous d_a
        Eventpoint::When_::AmbiguousNextStep[ d_a, self ]
        @_ok = false
        UNABLE_
      end

      def __when_one_formal_transition trans_d  # panic or add one step and succeed

        reg_trans = @all_formal_transitions.fetch trans_d
        fo_trans = reg_trans.formal_transition

        sym = fo_trans.destination_symbol
        @_cycle_sanity_check[ sym ] && self._COVER_ME__solution_has_cycled__
        @_cycle_sanity_check[ sym ] = true

        if fo_trans.imperative_not_optional
          @_imperative_transition_pool.delete trans_d
        end

        _pend_ex = @all_pending_executions.fetch reg_trans.pending_execution_offset

        @_path.push Step___.new( _pend_ex.mixed_task_identifier, fo_trans )

        @current_state_symbol = sym

        ACHIEVED_
      end

      def __current_state_is_ending_state

        # (experimentally) rather than specify directly (in the graph or in
        # arguments) what the ending state is, we will define AN ending state
        # as any state that has no formal transitions from it. this assumes
        # [#004.B]

        _eventpoint = @_nodes_box_hash.fetch @current_state_symbol
        ! _eventpoint.can_transition_to
      end

      def __index_all_formal_transitions

        pool_of_imperative_transitions = {}
        active_formal_transitions_via_source = {}
        passive_formal_transitions_via_source = {}
        all_formal_transitions = []

        pending_executions = remove_instance_variable(
          :@pending_execution_pool ).pending_executions

        graph = remove_instance_variable :@graph
        verify = graph.nodes_box.h_.dup
        verify.default_proc = -> h, k do
          raise Eventpoint::KeyError, __say_levenschtein( k, h )
        end

        pending_executions.each_with_index do |pe, ex_d|

          pe.agent_profile.formal_transitions.each do |ft|

            # ~( validation begin
            eventpoint = verify[ ft.from_symbol ]  # raise
            a = eventpoint.can_transition_to
            if ! ( a and a.include? ft.destination_symbol )
              verify[ ft.destination_symbol ]  # raise
              raise Eventpoint::RuntimeError, __say_invalid_trans( ft, pe, eventpoint )
            end
            # ~)

            trans_d = all_formal_transitions.length
            all_formal_transitions.push RegisteredTransition___.new( ex_d, ft )

            from_sym = ft.from_symbol
            if ft.imperative_not_optional
              pool_of_imperative_transitions[ trans_d ] = true
              a = ( active_formal_transitions_via_source[ from_sym ] ||= [] )
            else
              a = ( passive_formal_transitions_via_source[ from_sym ] ||= [] )
            end
            a.push trans_d
          end
        end

        @active_formal_transitions_via_source = active_formal_transitions_via_source
        @passive_formal_transitions_via_source = passive_formal_transitions_via_source

        pending_executions.frozen? || self._EASY__just_dup_and_freeze__
        @all_pending_executions = pending_executions
        @all_formal_transitions = all_formal_transitions.freeze

        @current_state_symbol = graph.beginning_state_symbol
        @_nodes_box_hash = graph.nodes_box.h_

        @_imperative_transition_pool = pool_of_imperative_transitions
        @_cycle_sanity_check = { @current_state_symbol => true }
        @_path = []

        NIL
      end

      def __say_invalid_trans ft, pe, eventpoint  # formal transition, pending execution
        Eventpoint::When_::Say_invalid_transition[ ft, pe, eventpoint ]
      end

      def __say_levenschtein k, h
        "unrecognized node '#{ k }'. #{
          }did you mean #{ Common_::Oxford_or[ h.keys.map(&:id2name) ] }?"  # more like DON'T say levenschtein
      end

      attr_reader(
        :all_formal_transitions,
        :all_pending_executions,
        :current_state_symbol,
        :graph,
        :listener,
      )
    # -

    # ==

    RegisteredTransition___ = ::Struct.new :pending_execution_offset, :formal_transition
    Path___ = ::Struct.new :steps
    Step___ = ::Struct.new :mixed_task_identifier, :formal_transition

    # ==
  end
end
# :#tombstone-A: (could be temporary) remove legacy code (all) we are about to rewrite
