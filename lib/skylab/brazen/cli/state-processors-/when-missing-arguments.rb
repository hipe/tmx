module Skylab::Brazen

  module CLI

    class State_Processors_::When_Missing_Arguments

      def initialize event, action, client
        @property = event.property
        @render = client.help_renderer
        @render.set_action action  # eew
      end

      def execute
        o = @render
        prop = @property
        o.express do
          "expecting #{ par prop }"
        end
        o.output_usage_line
        o.output_invite_to_general_help
        GENERIC_ERROR_
      end
    end
  end
end
