module Skylab::TanMan

  class CLI < Brazen_::CLI

    class << self
      def new * a
        new_top_invocation TanMan_, * a
      end
    end
  end
end
