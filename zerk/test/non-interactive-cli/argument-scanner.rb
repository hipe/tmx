module Skylab::Zerk::TestSupport

  module Non_Interactive_CLI

    module Argument_Scanner

      def self.[] tcc
        tcc.include self
      end

      # -

        def real_scanner_for_ * s_a
          Common_::Polymorphic_Stream.via_array s_a
        end

        def define_by_ & p
          subject_module_.define( & p )
        end

        def begin_emission_spy_
          Common_.test_support::Expect_Emission_Fail_Early::Spy.new
        end

        def expression_agent
          Home_::NonInteractiveCLI::ArgumentScannerExpressionAgent.instance
        end

        def subject_module_
          Home_::NonInteractiveCLI::MultiModeArgumentScanner
        end

        def the_empty_real_scanner_
          Common_::Polymorphic_Stream.the_empty_polymorphic_stream
        end
      # -
    end
  end
end
