module Skylab::BeautySalon

  class CLI < Home_.lib_.brazen::CLI

    def self.new * a
      new_top_invocation a, Home_.application_kernel_
    end

    def expression_agent_class
      Brazen_::CLI::Expression_Agent
    end
  end
end
