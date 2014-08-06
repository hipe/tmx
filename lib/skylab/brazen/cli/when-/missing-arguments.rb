module Skylab::Brazen

  module CLI

    class When_::Missing_Arguments

      def initialize ev, help_renderer
        @property = ev.property
        @render = help_renderer
      end

      def execute
        o = @render ; prop = @property
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
