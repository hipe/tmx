module Skylab::Brazen

  module CLI

    class State_Processors_::When_No_Arguments

      def initialize client
        @application = client
        @expression_agent = client.expression_agent
        @stderr = client.stderr
      end

      def execute
        client = @application
        exp = @expression_agent ; out = @stderr
        exp.calculate do
          out.puts "expecting #{ par 'action' }"
          out.puts client.usage_line
          out.puts client.invite_to_general_help_line
        end
        GENERIC_ERROR_
      end
    end
  end
end
