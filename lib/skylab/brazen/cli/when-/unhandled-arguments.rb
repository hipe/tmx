module Skylab::Brazen

  class CLI

    class When_::Unhandled_Arguments < As_Bound_Call_

      def initialize args, help_renderer
        @args = args
        @render = help_renderer
      end

      def produce_result
        a = @args
        @render.express do
          "(unhandled argument#{ s a }: #{ a * ', ' })"
        end
        GENERIC_ERROR_EXITSTATUS
      end
    end
  end
end
