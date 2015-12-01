module Skylab::Brazen

  class CLI

    class When_::No_Arguments < As_Bound_Call_

      def initialize prop, help_renderer
        @prop = prop
        @render = help_renderer
      end

      def produce_result
        o = @render
        prop = @prop
        o.express { "expecting #{ par prop }" }
        o.express_primary_usage_line_
        o.express_invite_to_general_help
        GENERIC_ERROR_EXITSTATUS
      end
    end
  end
end
