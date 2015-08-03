module Skylab::Brazen

  class CLI

    class When_::Parse_Error < As_Bound_Call_

      def initialize e, help_renderer
        @exception = e
        @render = help_renderer
      end

      def produce_result
        o = @render
        o.y << @exception.message
        o.express_invite_to_general_help
        GENERIC_ERROR
      end
    end
  end
end
