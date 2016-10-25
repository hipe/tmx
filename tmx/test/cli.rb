module Skylab::TMX::TestSupport

  module CLI

    def self.[] tcc

      tcc.send :define_singleton_method, :given_, DEFINITION_FOR_THE_METHOD_CALLED_GIVEN___

      if false
      Home_.lib_.brazen.test_support.lib( :CLI_support_expectations )[ tcc ]
      end
      tcc.include self
    end

    # -
      DEFINITION_FOR_THE_METHOD_CALLED_GIVEN___ = -> s_a do
        define_method :prepare_CLI do |cli|
          _st = TS_::Operations::Map::Dir01::JSON_file_stream_via[ s_a ]
          cli.json_file_stream_by { _st } ; nil
        end
      end
    # -

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
