module Skylab::TestSupport

  class CLI::Test_Support_Client___ < Home_.lib_.brazen::CLI

    # ~ we want this to go away eventually

    class << self

      def new_via_arglist a
        new_top_invocation a, Home_::API.krnl
      end
    end  # >>

    # ~ the currently cludgy way we get resources directly to the model action

    CLI_Client_ = self

    module Actions

      class Cover < CLI_Client_::Action_Adapter

        def receive_frame x
          super
          @bound.sout = @resources.sout
          @bound.serr = @resources.serr
          @bound.invocation_string_array =
            @resources.invocation_string_array
          nil
        end

        def bound_call_from_parse_options
          # don't let the option parser swallow the '--' "early"
          nil
        end
      end
    end

    def expression_agent_class
      Home_::CLI::Expression_Agent
    end
  end
end
