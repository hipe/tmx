module Skylab::Brazen

  module CLI

    class State_Processors_::When_No_Arguments

      def initialize client
        @render = client.help_renderer
      end

      def execute
        o = @render
        o.express { "expecting #{ par 'action' }" }
        o.output_usage_line
        o.output_invite_to_general_help
        GENERIC_ERROR_
      end
    end
  end
end
