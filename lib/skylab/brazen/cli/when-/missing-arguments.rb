module Skylab::Brazen

  class CLI

    class When_::Missing_Arguments < As_Bound_Call_

      def initialize ev, help_renderer
        @property = ev.property
        @render = help_renderer
      end

      def produce_result o = @render ; prop = @property
        o.express do
          "expecting #{ par prop }"
        end
        o.express_primary_usage_line_
        o.express_invite_to_general_help
        GENERIC_ERROR
      end
    end
  end
end
