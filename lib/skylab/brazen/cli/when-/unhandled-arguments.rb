module Skylab::Brazen

  class CLI

    class When_::Unhandled_Arguments < Simple_Bound_Call_

      def initialize args, help_renderer
        @args = args
        @render = help_renderer
      end

      def produce_any_result
        a = @args
        @render.express do
          "(unhandled argument#{ s a }: #{ a * ', ' })"
        end
        GENERIC_ERROR_
      end
    end
  end
end
