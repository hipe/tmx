module Skylab::Arc

  class Magnetics_::Mutate_via_ArgumentScanner_and_Verb_and_ACS

    # notes in [#002]
    # -

      def initialize & oes_p_p
        if oes_p_p
          if 1 == oes_p_p.arity
            @pp_ = oes_p_p
          else
            self._BECOME_THE_FUTURE
          end
        else
          @pp_ = No_handler___
        end
      end

      No_handler___ = -> _ do

        -> * i_a, & ev_p do
          raise "handle me: #{ i_a.inspect }"
        end
      end

      attr_writer(
        :ACS,
        :argument_scanner,
        :macro_operation_method_name,
      )

      def accept_argument_array x_a
        @argument_scanner = Common_::Scanner.via_array x_a
        NIL_
      end

      def execute

        if @argument_scanner.unparsed_exists
          send :"__do__#{ @macro_operation_method_name }__"
        else
          self._COVER_ME
        end
      end

      def __do__create__

        @_fully_or_passively = :fully
        _create_or_interpret
      end

      def __do__interpret__

        @_fully_or_passively = :passively
        _create_or_interpret
      end

      def _create_or_interpret

        _ok = _prepare_unit_of_work_queue
        _ok && __result_for_create_or_interpret
      end

      def __do__edit__

        _ok = _prepare_unit_of_work_queue
        _ok && __result_for_edit
      end

      def __result_for_create_or_interpret

        if @argument_scanner.unparsed_exists && :passively != @_fully_or_passively
          raise ::ArgumentError, @argument_scanner.head_as_is
        end

        if @_unit_of_work_queue.length.zero?
          self._COVER_ME
        else
          __result_for_create_or_interpret_when_nonzero_units
        end
      end

      def __result_for_edit

        if @argument_scanner.unparsed_exists
          raise ::ArgumentError, @argument_scanner.head_as_is
        end

        if @_unit_of_work_queue.length.zero?
          self._COVER_ME_no_arguments_to_mutation_stream
        else
          __result_for_edit_when_nonzero_units
        end
      end

      def __result_for_create_or_interpret_when_nonzero_units

        _deliver_nonzero_units_of_work

        if @_at_least_one_delivery_failed
          @_last_delivery_failure_result
        else
          @ACS
        end
      end

      def __result_for_edit_when_nonzero_units

        _deliver_nonzero_units_of_work

        if @_at_least_one_delivery_failed
          @_last_delivery_failure_result

        elsif @_at_least_one_delivery_changed_something

          if @ACS.respond_to? DID_CHANGE__

            _changelog = Change_Log___.new @_last_changeful_delivery_result
            @ACS.send DID_CHANGE__, _changelog, & @pp_
          else
            @_last_changeful_delivery_result
          end
        elsif @ACS.respond_to? NO_CHANGE__
          @ACS.send NO_CHANGE__, & @pp_
        else
          NIL_  # a no-op is not a success, by default (per this line (covered))
        end
      end

      DID_CHANGE__ = :result_for_component_mutation_session_when_changed
      NO_CHANGE__ = :result_for_component_mutation_session_when_no_change

      def _prepare_unit_of_work_queue

        _rw = Home_::Magnetics::OperatorBranch_via_ACS.for_componentesque @ACS
        # (#[#023] - a read/writer is one-to-one with an ACS, so etc..)

        a = []
        ok = ACHIEVED_

        p = Home_::Operation::Imperative_Phrase.call_via_these__(
          @argument_scanner,
          _rw,
          & @pp_ )

        begin
          ph = p[]
          ph or break
          uow = ph.to_unit_of_work
          if uow
            a.push uow
            redo
          end
          ok = uow
          break
        end while nil

        if ok
          @_unit_of_work_queue = a
        end
        ok
      end

      def _deliver_nonzero_units_of_work

        @_at_least_one_delivery_failed = false
        @_at_least_one_delivery_changed_something = false

        ok = true
        @_unit_of_work_queue.each do |de|

          dr = de.deliver  # delivery result
          ok = send :"__when__#{ dr.delivery_status }__", dr
          ok or break
        end

        NIL_
      end

      def __when__the_IF_condition_was_not_met__ op

        # if an IF condition is not met we continue with the edit session
        # but we do not classify this delivery as a change.

        ACHIEVED_  # keep delivering
      end

      def __when__an_assumption_was_incorrect__ op

        # if an assumption is not met we cancel the edit session halway thru

        @_at_least_one_delivery_failed = true
        @_last_delivery_failure_result = op.failure_value

        UNABLE_  # stop delivering
      end

      def __when__delivery_was_rejected__ op

        # if a delivery is rejected we cancel the edit session halfway thru

        @_at_least_one_delivery_failed = true
        @_last_delivery_failure_result = op.failure_value

        UNABLE_  # stop delivering
      end

      def __when__delivery_succeeded__ op

        # if a delivery succeeds we interpret this to mean change occurred.

        @_at_least_one_delivery_changed_something = true
        @_last_changeful_delivery_result = op.delivery_value

        ACHIEVED_  # keep delivering
      end

      # -- for sub-clients

      attr_reader(
        :ACS,
        :argument_scanner,
        :pp_,
      )

      Change_Log___ = ::Struct.new :last_delivery_result

      Here_ = self
    # -
  end
end
