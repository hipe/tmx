module Skylab::TMX::TestSupport

  module Modalities::CLI

    def self.[] tcc

      Home_.lib_.brazen.test_support.lib( :CLI_support_expectations )[ tcc ]
      tcc.include self
    end

    # ~ hook-outs

    def get_invocation_strings_for_expect_stdout_stderr
      [ 'zizzy' ]  # client freezes
    end
  end
end
