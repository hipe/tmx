module Skylab::Brazen

  module CLI

    class State_Processors_::When_Parse_Error

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
