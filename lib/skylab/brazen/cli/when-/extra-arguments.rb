module Skylab::Brazen

  module CLI

    class When_::Extra_Arguments

      def initialize event, action, client
        @event = event
        @render = client.help_renderer
        @render.set_action action  # eew
      end

      def execute
        o = @render
        x = @event.x
        o.express do
          "unexpected argument #{ ick x }"
        end
        o.output_usage_line
        o.output_invite_to_general_help
        GENERIC_ERROR_
      end
    end
  end
end
