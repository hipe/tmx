module Skylab::TMX::TestSupport

  module CLI

    def self.[] tcc

      tcc.extend ModuleMethods___
      tcc.include InstanceMethods___

      if false
      Home_.lib_.brazen.test_support.lib( :CLI_support_expectations )[ tcc ]
      end
    end

    module ModuleMethods___

      def given_test_directories s_a
        define_method :prepare_CLI do |cli|
          _st = TS_::Operations::Map::Dir01::JSON_file_stream_via[ s_a ]
          cli.json_file_stream_by { _st } ; nil
        end
      end

      def given & p
        x = nil ; yes = true
        define_method :the_givens do
          if yes
            yes = false
            @the_givens = Givens___.new
            instance_exec( & p )
            x = remove_instance_variable :@the_givens
            x
          else
            For_now_fail_with_this_message___[]
          end
        end
      end
    end

    # ==

    For_now_fail_with_this_message___ = -> do
      fail "needs consideration - etc"
    end

    Givens___ = ::Struct.new :argv

    # ==

    module InstanceMethods___

      # -- setup

      def will_invoke_via_argv argv
        @the_givens.argv = argv ; nil
      end

      def invoke_it
        _argv = the_givens.argv
        invoke_via_argv _argv
        NIL
      end

      # -- assert

      def expect_failed_normally_
        expect "try 'tmz -h'"
        expect_failed
      end

      # --

      def prepare_CLI cli
        NOTHING_
      end

      define_method :program_name_string_array, ( Lazy_.call do
        %w( tmz )
      end )

      def subject_CLI
        Home_::CLI
      end
    end

    if false
    # ~ hook-outs

    def get_invocation_strings_for_expect_stdout_stderr
      [ 'zizzy' ]  # client freezes
    end
    end
  end
end
