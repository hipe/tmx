module Skylab::Brazen

  module CLI

    class State_Processors_::When_Parse_Error

      def initialize e, client, out=client.stderr
        @client = client ; @exception = e
        @out = out
      end

      def execute
        @out.puts @exception.message
        @out.puts @client.invite_to_general_help_line
        GENERIC_ERROR_
      end
    end
  end
end
