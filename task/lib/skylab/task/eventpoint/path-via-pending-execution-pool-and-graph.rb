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

        begin
          __accept_any_and_all_stationary_transitions
          if __current_state_is_ending_state
            break
          end
          _yes = __resolve_one_single_active_transition_for_this_step
          _yes && redo
          @_ok || break
          _yes = __resolve_one_single_passive_transition_for_this_step
          _yes && redo
          @_ok || break
          __whine_about_how_no_transition_was_found
          break
        end while above

        if @_ok
          __check_that_all_imperative_transitions_were_employed
        end

        if @_ok
          __maybe_mention_that_there_are_some_unemployed_pending_executions
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
          Eventpoint::When_::UnmetImperativeTransitions.call(
            h.keys, self )
        end
        NIL
      end

      def __maybe_mention_that_there_are_some_unemployed_pending_executions
        #coverpoint-1.1.2 - this does not cause failure, is just a notice
        h = remove_instance_variable :@_pending_execution_pool
        if h.length.nonzero?
          Eventpoint::When_::UnutilizedPendingExecution.call(
            h.keys, self )
        end
        NIL
      end

      def __flush_path
        Path___.new remove_instance_variable( :@_path ).freeze
      end

      def __accept_any_and_all_stationary_transitions

        # stationary transitions are easy because they don't move state.
        # for each current node, accept any and all of them. they arrive
        # in the path in the order in which they were specified.
        # be sure to tick off the pending execution as having been did.
        # be sure to tick off any required formal transition as having been did

        d_a = @stationary_formal_transitions_via_source[ @current_state_symbol ]
        if d_a
          d_a.each do |trans_d|
            _accept_transition trans_d
          end
        end
        NIL
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

        # (the check for cycling happens here but not in the part of the
        # method that is also used for handling stationary transitions.
        # we aren't worried about stationary transitions, but for stationary
        # ones if we don't check for cycling there's nothing to stop it..)

        sym = @all_formal_transitions.fetch( trans_d ).
          formal_transition.destination_symbol

        @_cycle_sanity_check[ sym ] && self._COVER_ME__solution_has_cycled__
        @_cycle_sanity_check[ sym ] = true

        _accept_transition trans_d
      end

      def _accept_transition trans_d

        reg_trans = @all_formal_transitions.fetch trans_d
        fo_trans = reg_trans.formal_transition

        if fo_trans.imperative_not_optional
          @_imperative_transition_pool.delete trans_d
        end

        ex_d = reg_trans.pending_execution_offset
        @_pending_execution_pool.delete ex_d

        # (multiple transitions can be associated with one pending
        # execution, so the above is not guaranteed to delete an entry.)

        _pend_ex = @all_pending_executions.fetch ex_d

        @_path.push Step___.new( _pend_ex.mixed_task_identifier, fo_trans )

        @current_state_symbol = fo_trans.destination_symbol

        ACHIEVED_
      end

      def __current_state_is_ending_state

        # (experimentally) rather than specify directly (in the graph or in
        # arguments) what the ending state is, we stipulate that an ending
        # state is any state that has no formal transitions from it. so this
        # (in contrast to before) allows you to have multiple ending states.
        #
        # assume [#004.B]: if the array exists it is nonzero in length.

        _eventpoint = @_nodes_box_hash.fetch @current_state_symbol
        ! _eventpoint.can_transition_to
      end

      def __index_all_formal_transitions

        imperative_transition_pool = {}
        pending_execution_pool = {}

        stationary_formal_transitions_via_source = {}
        active_formal_transitions_via_source = {}
        passive_formal_transitions_via_source = {}

        all_formal_transitions = []

        pending_executions = remove_instance_variable(
          :@pending_execution_pool ).pending_executions

        __init_verifier
        graph = remove_instance_variable :@graph

        trans_d = nil

        note_it_is_imperative = -> do
          imperative_transition_pool[ trans_d ] = true
        end

        pending_executions.each_with_index do |pe, ex_d|

          pe.agent_profile.formal_transitions.each do |ft|

            __verify ft, pe

            trans_d = all_formal_transitions.length
            all_formal_transitions.push RegisteredTransition___.new( ex_d, ft )

            from_sym = ft.from_symbol

            if ft.is_stationary

              if ft.imperative_not_optional

                note_it_is_imperative[]
              end
              a = ( stationary_formal_transitions_via_source[ from_sym ] ||= [] )

            elsif ft.imperative_not_optional

              note_it_is_imperative[]

              a = ( active_formal_transitions_via_source[ from_sym ] ||= [] )
            else
              a = ( passive_formal_transitions_via_source[ from_sym ] ||= [] )
            end

            a.push trans_d
          end

          pending_execution_pool[ ex_d ] = true
        end

        @stationary_formal_transitions_via_source = stationary_formal_transitions_via_source
        @active_formal_transitions_via_source = active_formal_transitions_via_source
        @passive_formal_transitions_via_source = passive_formal_transitions_via_source

        pending_executions.frozen? || self._EASY__just_dup_and_freeze__
        @all_pending_executions = pending_executions
        @all_formal_transitions = all_formal_transitions.freeze

        @current_state_symbol = graph.beginning_state_symbol
        @_nodes_box_hash = graph.nodes_box.h_

        @_imperative_transition_pool = imperative_transition_pool
        @_pending_execution_pool = pending_execution_pool

        @_cycle_sanity_check = { @current_state_symbol => true }
        @_path = []

        NIL
      end

      def __verify ft, pe  # formal transition, pending execution

        # to this point the agent profile could have used any symbolic names
        # whatsover in specifying its formal transitions. of every formal
        # transition declared, both ends of it must be correspond to
        # existent nodes in the graph, and the transition itself (the arc)
        # must exist in the graph too.
        #
        # for all nodes, the transition may be declared that transitions
        # from that node to itself; as discussed at #coverpoint-1.1.1.

        from_sym = ft.from_symbol
        dest_sym = ft.destination_symbol

        eventpoint = @_verify[ from_sym ]  # raise

        if ! ft.is_stationary
          a = eventpoint.can_transition_to
          if a
            if a.include? ft.destination_symbol  # ..
              NOTHING_  # hi.
            else
              failed = true
            end
          else
            failed = true  # per [#004.B] you hit here IFF no transitions
          end
        end

        if failed

          # in cases where both problems exist, which do you want to take
          # precedence? that the source node has no destination nodes, or
          # that the destination node is an invalid name? we chose the
          # latter but this could change.

          @_verify[ dest_sym ]  # raise
          raise Eventpoint::RuntimeError, __say_invalid_trans( ft, pe, eventpoint )
        end
      end

      def __init_verifier
        @_verify = graph.nodes_box.h_.dup
        @_verify.default_proc = -> h, k do
          raise Eventpoint::KeyError, __say_levenschtein( k, h )
        end
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
