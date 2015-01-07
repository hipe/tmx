module Skylab::Brazen

  class CLI

    class Action_Adapter_

      module Arguments

        class Normalization_Via__

          Callback_::Actor.call self,
            :properties,
              :parameters

          def execute

            _arg_a = @parameters.map do |a|
              Argument_via_Native_Parameter__.new( * a )
            end

            Normalization_.new _arg_a

          end

          class Argument_via_Native_Parameter__

            def initialize opt_req_rest_i, name_i
              @opt_req_rest_i = opt_req_rest_i
              @name_i = name_i
            end

            def has_default
              false
            end

            attr_reader :name_i

            def is_required
              :req == @opt_req_rest_i
            end

            def name
              @name ||= bld_name_function_with_hack
            end

          private

            def bld_name_function_with_hack
              Callback_::Name.via_variegated_symbol(
                Callback_::Name.variegated_human_symbol_via_variable_name_symbol @name_i )
            end
          end
        end
      end
    end
  end
end
