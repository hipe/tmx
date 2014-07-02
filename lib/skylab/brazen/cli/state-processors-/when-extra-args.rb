module Skylab::Brazen

  module CLI

    class State_Processors_::When_Extra_Args
      def initialize args, client
        @args = args ; @client = client
        @expression_agent = client.expression_agent ; @out = client.stderr
      end

      def execute
        a = @args ; out = @out
        @expression_agent.calculate do
          out.puts "(unhandled argument#{ s a }: #{ a * ', ' })"
        end
        GENERIC_ERROR_
      end
    end
  end
end
