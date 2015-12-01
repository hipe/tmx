module Skylab::Brazen

  class CLI

    class Action_Adapter_

      module Arguments

        class Normalization_Via__

          Callback_::Actor.call self,
            :properties,
              :parameters

          def execute
            Normalization_.new( @parameters.map do |a|
              Argument_via_Native_Parameter__.new( * a )
            end )
          end

          class Argument_via_Native_Parameter__

            def initialize opt_req_rest_i, name_symbol
              @opt_req_rest_i = opt_req_rest_i
              @name_symbol = name_symbol
            end

            def has_default
              false
            end

            attr_reader :name_symbol

            def is_required
              :req == @opt_req_rest_i
            end

            def name
              @name ||= bld_name_function_with_hack
            end

          private

            def bld_name_function_with_hack
              Callback_::Name.via_variegated_symbol(
                Callback_::Name.variegated_human_symbol_via_variable_name_symbol @name_symbol )
            end
          end
        end
      end
    end
  end
end
