module Skylab::Cull

  class CLI < Brazen_::CLI

    class << self
      def new * a
        new_top_invocation a, Home_.application_kernel_
      end
    end  # >>

    def expression_agent_class  # #hook-in [br]
      Brazen_::CLI.expression_agent_class
    end
  end
end
