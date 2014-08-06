module Skylab::Brazen

  module CLI

    class When_::No_Arguments

      def initialize prop, help_renderer
        @prop = prop
        @render = help_renderer
      end

      def execute
        o = @render
        prop = @prop
        o.express { "expecting #{ par prop }" }
        o.output_usage_line
        o.output_invite_to_general_help
        GENERIC_ERROR_
      end
    end
  end
end
