module Skylab::Permute

  module CLI

    class << self

      def new argv, sin, sout, serr, pn_s_a

        o = Zerk_lib_[]::NonInteractiveCLI.begin

        o.argv = argv

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

        if block_given?
          o.write_exitstatus = yield.method :exitstatus=
        end

        o.finish
      end
    end

    Customization_for_the_generate_operation = -> oper_cust do

      oper_cust.custom_option_parser_by do |fr|

        copg = Here_::CustomOptionParserGeneration.begin_for fr

        # our custom option parser is in effect obviating the below term: we
        # don't want it to appear in help screens and we don't want the arg-
        # parsing phase to try and parse this term (which, without this,
        # would typically fail because of a missing required argument).

        fr.remove_positional_argument :value_name_pair

        copg.handle_value_name_stream_by do |vns, rsx|

          _par = fr.formal_parameter :value_name_pairs
          _ast = rsx.lib::Assignment.new vns, _par
          rsx.setter[ NOTHING_, _ast ]
          NIL
        end

        copg.finish
      end
    end

    Here_ = self
  end
end
