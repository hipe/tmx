module Skylab::Brazen

  module CLI

    class When_::Unhandled_Arguments

      def initialize args, client
        @args = args
        @render = client.help_renderer
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
