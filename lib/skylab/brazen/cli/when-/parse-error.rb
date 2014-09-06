module Skylab::Brazen

  class CLI

    class When_::Parse_Error < Simple_Bound_Call_

      def initialize e, help_renderer
        @exception = e
        @render = help_renderer
      end

      def execute
        o = @render
        o.y << @exception.message
        o.output_invite_to_general_help
        GENERIC_ERROR_
      end
    end
  end
end
