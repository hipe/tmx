module Skylab::Brazen

  module Autonomous_Component_System

    class Mutation  # notes in [#089]

      def initialize & x_p
        @x_p = x_p || Unhandler___
      end

      Unhandler___ = -> * i_a, & _ev_p do
        raise "handle me: #{ i_a.inspect }"
      end

      attr_writer(
        :ACS,
        :arg_st,
        :macro_operation_method_name,
      )

      def accept_argument_array x_a
        @arg_st = Callback_::Polymorphic_Stream.via_array x_a
        NIL_
      end

      def execute

        if @arg_st.unparsed_exists
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

        if @arg_st.unparsed_exists && :passively != @_fully_or_passively
          raise ::ArgumentError, @arg_s.current_token
        end

        if @_unit_of_work_queue.length.zero?
          self._COVER_ME
        else
          __result_for_create_or_interpret_when_nonzero_units
        end
      end

      def __result_for_edit

        if @arg_st.unparsed_exists
          raise ::ArgumentError, @arg_s.current_token
        end

        if @_unit_of_work_queue.length.zero?
          self._COVER_ME
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

          @ACS.result_for_component_mutation_session_when_changed(
            Change_Log___.new( @_last_changeful_delivery_result ),
            & @x_p )
        else

          @ACS.result_for_component_mutation_session_when_no_change( & @x_p )
        end
      end

      def _prepare_unit_of_work_queue

        a = []
        ok = ACHIEVED_

        p = Operation___.gets_proc_for @arg_st, @ACS, & @x_p

        begin
          op = p[]
          op or break
          ok = op.interpret
          ok or break
          a.push op
          redo
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
        @_unit_of_work_queue.each do | op |

          op.deliver
          ok = send :"__when__#{ op.delivery_status }__", op
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
        @_last_delivery_failure_result = op.delivery_value

        UNABLE_  # stop delivering
      end

      def __when__delivery_was_rejected__ op

        # if a delivery is rejected we cancel the edit session halfway thru

        @_at_least_one_delivery_failed = true
        @_last_delivery_failure_result = op.delivery_value

        UNABLE_  # stop delivering
      end

      def __when__delivery_succeeded__ op

        # if a delivery succeeds we interpret this to mean change occurred.

        @_at_least_one_delivery_changed_something = true
        @_last_changeful_delivery_result = op.delivery_value

        ACHIEVED_  # keep delivering
      end

      class Operation___

        class << self

          def gets_proc_for st, acs, & x_p

            p = nil

            done = -> do
              p = EMPTY_P_ ; nil
            end

            p = -> do
              if st.no_unparsed_exists
                done[]
              else
                new st, acs, & x_p   # we cannot parse yet - see "2 channel" here
              end
            end

            -> do
              p[]
            end
          end

          private :new
        end  # >>

        def initialize arg_st, acs, & x_p

          @arg_st = arg_st
          @modifiers = nil
          @oes_p = x_p

          _accept_ACS acs
        end

        def interpret

          # "2 channel": the presence or absence of any apparent next
          # operation in the stream is distinct from whether that operation
          # parses successfully, which is distinct from whether the operation
          # is received without failure upon delivery.

          if @ACS.respond_to? :"__#{ @arg_st.current_token }__component_operation"
            __interpret_as_self
          else
            p = MODIFIERS__[ @arg_st.current_token ]
            if p
              __modifiers p
            end
            @operation_symbol = @arg_st.gets_one
            __interpret_deeply
          end
        end

        def __modifiers p

          @modifiers = Modifiers___.new

          begin
            @arg_st.advance_one
            p[ @modifiers, @arg_st ]  # cannot soft fail

            p = MODIFIERS__[ @arg_st.current_token ]
            p ? redo : break
          end while nil
          NIL_
        end

        def __interpret_deeply

          st = @arg_st
          begin

            # current token must be an association

            @association = @assoc_reader[ st.gets_one ]

            # if that association recognizes the operation, success.

            mode = @association.any_delivery_mode_for @operation_symbol
            if mode
              break
            end

            if st.no_unparsed_exists
              break
            end

            # if the association itself has an association by this name..

            if @association.model_has_association st.current_token
              __descend
              redo
            end

            break
          end while nil

          if mode
            @_delivery_mode = mode
            __interpret_via_delivery_mode
          else
            raise ::ArgumentError, __say_cannot
          end
        end

        def __descend

          _ = ACS_::For_Interface::Read_or_write[ @association, @ACS, & @oes_p ]
          _accept_ACS _
          @association = nil
        end

        def _accept_ACS acs

          @assoc_reader = Component_Association.reader_for acs
          @ACS = acs ; nil
        end

        def __say_cannot

          a_i = @arg_st.current_token
          a = @association.operation_symbols
          v_i = @operation_symbol

          if a.length.zero?
            "no operations defined for '#{ a_i }' - cannot '#{ v_i }'"
          else
            "cannot '#{ v_i }' an '#{ a_i }' - can only #{ a * ' or ' }"
          end
        end

        def __interpret_via_delivery_mode
          send :"__interpret_when_operation_defined_in__#{ @_delivery_mode }__"
        end

        def __interpret_when_operation_defined_in__association__

          @modifiers ||= NO_MODIFIERS__

          sym = @modifiers.via
          if sym  # :t7.

            comp_x = @association.component_model.send(
              :"new_via__#{ sym }__",
              @arg_st.gets_one,
              & @oes_p
            )
            ok = comp_x ? true : false
          else

            wv = ___interpret_component_normally
            if wv
              ok = true
              comp_x = wv.value_x
            else
              ok = wv
            end
          end

          if ok
            @_sub_component_x = comp_x
            INTERPRETATION_SUCCEEDED__
          else
            ok
          end
        end

        def ___interpret_component_normally

          o = ACS_::Interpretation_::Build_Value.new(
            @association, @ACS, & @oes_p )

          o.wrap_handler_as_component_handler
          o.mixed_argument = @arg_st
          o.execute
        end

        def __interpret_when_operation_defined_in__model__

          _normalize_when_model_op
          ( o = dup ).extend ACS_::Operation::Preparation::Deep_Methods
          _interpret_when_model_op_via o
        end

        def __interpret_as_self

          @_delivery_mode = :model  # be careful
          @operation_symbol = @arg_st.gets_one

          _normalize_when_model_op
          ( o = dup ).extend ACS_::Operation::Preparation::Self_Methods
          _interpret_when_model_op_via o
        end

        def _normalize_when_model_op

          if @modifiers
            raise ::ArgumentError, self._COVER_ME
          else
            @modifiers = NO_MODIFIERS__
            NIL_
          end
        end

        def _interpret_when_model_op_via o
          ok = o.prepare
          if ok
            @ACS = o.ACS  # might be same
            @args = o.args
            @operation = o.operation
            INTERPRETATION_SUCCEEDED__
          else
            ok
          end
        end

        def deliver

          if @modifiers.has_conditions
            __deliver_when_conditions_exist
          else
            _deliver_when_all_conditions_cleared
          end
        end

        def __deliver_when_conditions_exist

          if @modifiers.if
            if __evaluate_the_IF_conditional
              if @modifiers.assuming
                _deliver_when_unevaluated_assumptions_exist
              else
                _deliver_when_all_conditions_cleared
              end
            else
              @delivery_status = :the_IF_condition_was_not_met
            end
          else
            _deliver_when_unevaluated_assumptions_exist
          end
          NIL_
        end

        def __evaluate_the_IF_conditional

          # (we used to simply negate the results, but no longer, per t7D)

          if_o = @modifiers.if

          _m = if if_o.is_negated
            :"component_is_not__#{ if_o.symbol }__"
          else
            :"component_is__#{ if_o.symbol }__"
          end

          @ACS.send(
            _m,
            @_sub_component_x,
            @association,
            & @oes_p )
        end

        def _deliver_when_unevaluated_assumptions_exist

          last_value = nil

          @modifiers.assuming.each do | assu |

            _m = if assu.is_negated
              :"expect_component_not__#{ assu.symbol }__"
            else
              :"expect_component__#{ assu.symbol }__"
            end

            last_value = @ACS.send(
              _m,
              @_sub_component_x,
              @association,
              & @oes_p )

            last_value or break
          end

          if last_value
            _deliver_when_all_conditions_cleared
          else
            @_delivery_was_evaluated = true
            @_delivery_value = last_value
            @delivery_status = :an_assumption_was_incorrect
          end
          NIL_
        end

        def _deliver_when_all_conditions_cleared

          send :"__deliver_when_operation_defined_in__#{ @_delivery_mode }__"
        end

        def __deliver_when_operation_defined_in__association__

          _x = @ACS.send(
            :"__#{ @operation_symbol }__component",
            * @modifiers.using,
            @_sub_component_x,
            @association,
            & @oes_p )

          _accept_delivery_value _x

          NIL_
        end

        def __deliver_when_operation_defined_in__model__

          _x = @operation.callable.call( * @args )

          _accept_delivery_value _x

          NIL_
        end

        def _accept_delivery_value x

          @_delivery_was_evaluated = true
          @_delivery_value = x
          if x
            @delivery_status = :delivery_succeeded
          else
            @delivery_status = :delivery_was_rejected
          end
          NIL_
        end

        attr_reader(
          :delivery_status,
        )

        def delivery_value
          if @_delivery_was_evaluated
            @_delivery_value
          else
            self._COVER_ME
          end
        end
      end

      # #open [#br-120] we would like to make the below extensible

      if_or_assuming = -> st do
        if :not == st.current_token
          is_negated = true
          st.advance_one
        end
        If_or_Assuming___.new is_negated, st.gets_one
      end

      MODIFIERS__ = {

        assuming: -> modz, st do
          if ! modz.assuming
            modz.assuming = []
          end
          modz.has_conditions = true
          modz.assuming.push if_or_assuming[ st ]
          NIL_
        end,

        if: -> modz, st do
          if modz.if
            self._COVER_ME  # this should be disallowed - bool semantics not clear
          end
          modz.has_conditions = true
          modz.if = if_or_assuming[ st ]
          NIL_
        end,

        using: -> modz, st do
          a = modz.using
          if ! a
            a = []
            modz.using = a
          end
          a.push st.gets_one
          NIL_
        end,

        via: -> modz, st do
          modz.via = st.gets_one
          NIL_
        end,
      }

      Change_Log___ = ::Struct.new :last_delivery_result

      Here_ = self

      If_or_Assuming___ = ::Struct.new :is_negated, :symbol

      INTERPRETATION_SUCCEEDED__ = true

      Modifiers___ = ::Struct.new :assuming, :has_conditions, :if, :using, :via

      NO_MODIFIERS__ = Modifiers___.new.freeze

    end
  end
end
