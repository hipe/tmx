module Skylab::Treemap

  class CLI < Brazen_::CLI

    # desc "experiments with R."

    class << self
      def new * a
        new_top_invocation a, Treemap_.application_kernel_
      end
    end

    def expression_agent_class
      Brazen_::CLI.expression_agent_class
    end
  end
end
