module Skylab::Arc

  module Operation

    module Delivery_

      class Deliverable  # 2x

        # basically a re-imagining of [#ca-059] "bound call" but with
        # implementation for our two modifiers-derived conditionals.

        def initialize modz, ss, bc

          if modz
            has_conditions = modz.has_conditions
            if has_conditions
              @_assuming = modz.assuming
              @_if = modz.if
            end
          end

          @_bound_call = bc
          @_has_conditions = has_conditions
          @selection_stack = ss
        end

        def deliver
          if @_has_conditions
            ___when_conditions
          else
            _deliver
          end
        end

        def ___when_conditions

          # assume has values for one or both of `if` and/or `assuming`

          if @_if
            if ___evaluate_the_IF_conditional
              if @_assuming
                _when_assuming
              else
                _deliver
              end
            else
              DELIV_RESULT_FOR_COND_NOT_MET___
            end
          else
            _when_assuming
          end
        end

        # as allued to in [#002]:Tenet7(D), to achieve negation we used to
        # simply negate the positive forms, but no longer: the reason we
        # call polarity-specific hook-out methods below is this: when it is
        # designed to do so from both ends, the client can now infer the
        # state that was probably expected at the time of attempted delivery.
        # when this state differs from "what is expected" the client can emit
        # expression (for example) that expresses this. imagine a
        # dup-checking conditional `already_added` - a contrived edit might
        # sound like "if not already_added add foo". because
        # "what is expected" is that "foo" has not already been added, in
        # those cases where this conditional evaluates to true the client
        # might want to emit a message explaining that the item was already
        # added and the delivery was skipped.

        def ___evaluate_the_IF_conditional

          _m = if @_if.is_negated
            :"component_is_not__#{ @_if.symbol }__"
          else
            :"component_is__#{ @_if.symbol }__"
          end

          bc = @_bound_call

          _yes = bc.receiver.send _m, * bc.args, & _emission_handler

          _yes
        end

        def _when_assuming

          last_value = nil

          @_assuming.each do |assu|

            _m = if assu.is_negated
              :"expect_component_not__#{ assu.symbol }__"
            else
              :"expect_component__#{ assu.symbol }__"
            end

            bc = @_bound_call
            last_value = bc.receiver.send _m, * bc.args, & _emission_handler

            last_value or break
          end

          if last_value
            _deliver
          else
            Incorrect_Assumption_Result___.new last_value
          end
        end

        def _deliver

          bc = @_bound_call
          x = bc.receiver.send bc.method_name, * bc.args, & bc.block
          x &&= ___after_deliver x
          if x
            Successful_Delivery_Result___.new x
          else
            Unsuccessful_Delivery_Result___.new x
          end
        end

        def ___after_deliver x

          # if there were "hops" we may need to attach the "floating" component

          if 2 != @selection_stack.length
            ___attach_floating_component
          end
          x
        end

        def ___attach_floating_component

          ss = @selection_stack

          _deliveree_frame = ss.fetch( -2 )
          _recipient_frame = ss.fetch( -3 )
          _reader_writer = _recipient_frame.reader_writer

          _ev_p = Home_::Magnetics::WriteComponent_via_QualifiedComponent_and_OperatorBranch.call(
            _deliveree_frame, _reader_writer
          ) do
            _nf_a = ss[ 1 .. -2 ].map( & :name )
            _LL = Home_.lib_.basic::List::Linked.via_array _nf_a
            _LL
          end

          ev = _ev_p[]

          _emission_handler.call( * ev.suggested_event_channel ) do
            ev
          end
          NIL_
        end

        # -- experimental -
        #    expose these four datapoints so this actually looks like a bound
        #    call (for [ze]) BUT look at everything you lose (before hooks
        #    and after hooks..) (used by [ze])

        def bound_call
          @_bound_call
        end

        # --

        def _emission_handler
          @___oes_p ||= ___carefully_determine_emission_handler
        end

        def ___carefully_determine_emission_handler

          p = @_bound_call.block
          if 1 == p.arity
            p[ NOTHING_ ]  # EEW
          else
            p
          end
        end
      end

      Unsuccessful_Delivery_Result___ = ::Struct.new :failure_value do

        def delivery_status
          :delivery_was_rejected
        end
      end

      Incorrect_Assumption_Result___ = ::Struct.new :failure_value do

        def delivery_status
          :an_assumption_was_incorrect
        end
      end

      Deliv_Result_for_Cond_Not_Met___ = ::Struct.new :delivery_status

      DELIV_RESULT_FOR_COND_NOT_MET___ = Deliv_Result_for_Cond_Not_Met___[
        :the_IF_condition_was_not_met ]

      Successful_Delivery_Result___ = ::Struct.new :delivery_value do

        def delivery_status
          :delivery_succeeded
        end
      end
    end
  end
end
