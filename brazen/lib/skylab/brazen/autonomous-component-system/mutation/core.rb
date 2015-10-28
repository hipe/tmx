module Skylab::Brazen

  module Autonomous_Component_System

    class Sessions_::Mutation  # see [#089]

      class << self
        def event_class sym
          Mutation_Session_::Event_Factory_.class_for sym
        end
      end  # >>

      def initialize & x_p
        @x_p = x_p
      end

      attr_writer(
        :arg_st,
        :macro_operation_method_name,
        :subject_component,
      )

      def accept_argument_array x_a
        @arg_st = Callback_::Polymorphic_Stream.new x_a
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
          @subject_component
        end
      end

      def __result_for_edit_when_nonzero_units

        _deliver_nonzero_units_of_work

        if @_at_least_one_delivery_failed
          @_last_delivery_failure_result

        elsif @_at_least_one_delivery_changed_something

          @subject_component.
            result_for_component_mutation_session_when_changed(
              Change_Log___.new( @_last_changeful_delivery_result ),
              & @x_p )
        else

          @subject_component.
            result_for_component_mutation_session_when_no_change( & @x_p )
        end
      end

      def _prepare_unit_of_work_queue

        a = []
        ok = ACHIEVED_
        p = Operation___.new( @arg_st, @subject_component, & @x_p ).build_p

        begin
          op = p[]
          op or break
          ok = op.prepare
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

        def initialize arg_st, comp, & x_p
          @arg_st = arg_st
          @component = comp
          @on_event_selectively = x_p
        end

        def build_p

          arg_st = @arg_st
          modifiers = nil

          try = -> do

            begin
              p = MODIFIERS___[ arg_st.current_token ]
              if p
                arg_st.advance_one
                modifiers ||= Modifiers___.new
                p[ modifiers, arg_st ]  # cannot soft fail
                redo
              end
            end while nil

            mystery_verb_sym = arg_st.gets_one

            _association_name_sym = arg_st.gets_one

            _moddies = if modifiers
              x = modifiers
              modifiers = nil
              x
            end

            otr = dup
            otr.__init _moddies, mystery_verb_sym, _association_name_sym
            otr
          end

          -> do
            if arg_st.unparsed_exists
              try[]
            end
          end
        end

        def __init moddies, mystery_verb_sym, assoc_name_sym
          @mystery_association_name_symbol = assoc_name_sym
          @mystery_verb_symbol = mystery_verb_sym
          @modifiers = moddies || NO_MODIFIERS___
          NIL_
        end

        def prepare  # see :#A.: this must be called more or less immediately

          @_association = Component_Association.via_symbol_and_component(
            @mystery_association_name_symbol, @component )

          if @_association.can @mystery_verb_symbol
            __resolve_sub_component
          else
            raise ::ArgumentError, __say_cannot
          end
        end

        def __say_cannot

          a_i = @mystery_association_name_symbol
          a = @_association.operation_name_symbols
          v_i = @mystery_verb_symbol

          if a.length.zero?
            "no operations defined for '#{ a_i }' - cannot '#{ v_i }'"
          else
            "cannot '#{ v_i }' an '#{ a_i }' - can only #{ a * ' or ' }"
          end
        end

        def __resolve_sub_component

          sym = @modifiers.via
          if sym  # :t7.

            comp_x = @_association.component_model.send(
              :"new_via__#{ sym }__",
              @arg_st.gets_one,
              & @on_event_selectively
            )
            ok = comp_x ? true : false
          else
            vw = @_association.interpret @arg_st, & @on_event_selectively
            if vw
              ok = true
              comp_x = vw.value_x
            else
              ok = vw
            end
          end

          if ok
            @_sub_component_x = comp_x
          end
          ok
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

          @component.send(
            _m,
            @_sub_component_x,
            @_association,
            & @on_event_selectively )
        end

        def _deliver_when_unevaluated_assumptions_exist

          last_value = nil

          @modifiers.assuming.each do | assu |

            _m = if assu.is_negated
              :"expect_component_not__#{ assu.symbol }__"
            else
              :"expect_component__#{ assu.symbol }__"
            end

            last_value = @component.send(
              _m,
              @_sub_component_x,
              @_association,
              & @on_event_selectively )

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

          x = @component.send(
            :"__#{ @mystery_verb_symbol }__component",
            * @modifiers.using,
            @_sub_component_x,
            @_association,
            & @on_event_selectively )

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

      MODIFIERS___ = {

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

      If_or_Assuming___ = ::Struct.new :is_negated, :symbol

      Modifiers___ = ::Struct.new :assuming, :has_conditions, :if, :using, :via

      Mutation_Session_ = self

      NO_MODIFIERS___ = Modifiers___.new.freeze

    end
  end
end
