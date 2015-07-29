module Skylab::Git

  class CLI < Home_.lib_.brazen::CLI

    Brazen_ = ::Skylab::Brazen

    def self.new * a
      new_top_invocation a, Home_::API.application_kernel_
    end

    def expression_agent_class
      Brazen_::CLI.expression_agent_class
    end
  end
end
