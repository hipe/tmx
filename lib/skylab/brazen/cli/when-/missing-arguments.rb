module Skylab::Brazen

  class CLI

    class When_::Missing_Arguments < Simple_Bound_Call_

      def initialize ev, help_renderer
        @property = ev.property
        @render = help_renderer
      end

      def produce_any_result o = @render ; prop = @property
        o.express do
          "expecting #{ par prop }"
        end
        o.output_primary_usage_line
        o.output_invite_to_general_help
        GENERIC_ERROR_
      end
    end
  end
end
