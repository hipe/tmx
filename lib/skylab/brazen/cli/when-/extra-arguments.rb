module Skylab::Brazen

  class CLI

    class When_::Extra_Arguments < As_Bound_Call_

      def initialize ev, help_renderer

        @render = help_renderer
        @x = ev.x
      end

      def produce_result

        o = @render
        x = @x

        o.express do
          "unexpected argument #{ ick x }"
        end

        o.express_primary_usage_line_

        o.express_invite_to_general_help

        GENERIC_ERROR
      end
    end
  end
end
