module Skylab::TMX::TestSupport

  module Modalities::CLI

    def self.[] tcc

      Home_.lib_.brazen.test_support.CLI::Expect_CLI[ tcc ]
      tcc.include self
    end

    # ~ hook-outs

    def get_invocation_strings_for_expect_stdout_stderr
      [ 'zizzy' ]  # client freezes
    end
  end
end
