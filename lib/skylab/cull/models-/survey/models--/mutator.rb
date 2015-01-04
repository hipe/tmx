module Skylab::Cull

  class Models_::Survey

    class Models__::Mutator

      def initialize survey, & oes_p
        @survey = survey
        @on_event_selectively = oes_p
      end

      def add arg, _box

        ok = true

        arg.value_x.each do | s |

          ok, args = Models_::Mutator.
            func_and_args_via_call_expression_and_module(
              s,
              Models_::Mutator::Items__,
              & @on_event_selectively )

          ok or break

          _add ok, args
        end

        ok
      end

      def _add function_class, any_arg_s_a

        @survey.touch_associated_entity_( :report ).add_function_call(
          any_arg_s_a, function_class, :mutator )

      end
    end
  end
end
