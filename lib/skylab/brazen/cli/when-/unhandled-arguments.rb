module Skylab::Brazen

  module CLI

    class When_::Unhandled_Arguments

      def initialize args, help_renderer
        @args = args
        @render = help_renderer
      end

      def execute
        a = @args
        @render.express do
          "(unhandled argument#{ s a }: #{ a * ', ' })"
        end
        GENERIC_ERROR_
      end
    end
  end
end
