module Skylab::BeautySalon

  class CLI < Home_.lib_.brazen::CLI

    def self.new * a
      new_top_invocation a, Home_.application_kernel_
    end

    def expression_agent_class
      Brazen_::CLI::Expression_Agent
    end

    # ~ #hook-out for [tmx] integration (this whole file)

    module Client
      Adapter = self
      For = self
      Face = self
      Of = self
      Hot = -> x, x_ do

        Home_.lib_.brazen::CLI::Client.fml Home_, x, x_
      end
    end

    if false

    class Expression_Agent___ < Brazen_::CLI.expression_agent_class

      define_method :ellipsulate__, -> do

        _A_RATHER_SHORT_LENGTH = 8

        p = -> s do
          p = Home_.lib_.basic::String.ellipsify.curry[ _A_RATHER_SHORT_LENGTH ]
          p[ s ]
        end

        -> s do
          p[ s ]
        end
      end.call
    end
    end
  end
end
