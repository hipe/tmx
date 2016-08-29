module Skylab::Permute

  module CLI

    class << self

      def new sin, sout, serr, pn_s_a

        o = Zerk_lib_[]::NonInteractiveCLI.begin

        o.universal_CLI_resources sin, sout, serr, pn_s_a

        o.root_ACS_by do
          Home_::AutonomousComponentSystem_.instance_
        end

        o.node_map = {
          generate: -> oper_cust do
            Customization_for_the_generate_operation[ oper_cust ]
            NIL
          end,
        }

        o.finish
      end
    end

    Customization_for_the_generate_operation = -> oper_cust do

      oper_cust.custom_option_parser_by do |fr|

        Here_::CustomOptionParserGeneration.begin_for( fr ).finish
      end
    end

    Here_ = self
  end
end
