module Skylab::TanMan

  class CLI < Brazen_::CLI

    class << self
      def new * a
        new_top_invocation a, TanMan_
      end
    end

    def resolve_app_kernel
      @app_kernel = TanMan_::API.application_kernel ; nil
    end
  end
end
