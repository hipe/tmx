module Skylab::TMX::TestSupport

  module CLI

    def self.[] tcc

      if false
      Home_.lib_.brazen.test_support.lib( :CLI_support_expectations )[ tcc ]
      end
      tcc.include self
    end

    # -
      def expect_failed_normally_
        expect "try 'tmz -h'"
        expect_failed
      end
    # -

    if false
    # ~ hook-outs

    def get_invocation_strings_for_expect_stdout_stderr
      [ 'zizzy' ]  # client freezes
    end
    end
  end
end
