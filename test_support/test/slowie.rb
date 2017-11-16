module Skylab::TestSupport::TestSupport

  module Slowie

    def self.[] tcc
      tcc.include self
    end

    # -

      def fails_because_no_test_directories_ sym

        want :error, :expression, :operation_parse_error, :missing_required_arguments do |y|

          y.first == "can't :#{ sym } without test directories. (maybe use :test_directory.)" || fail
        end

        want_result UNABLE_
      end

      def ignore_these_common_emissions_
        ignore_emissions_whose_terminal_channel_symbol_is :operator_resolved
      end

      def subject_API
        Home_::Slowie::API
      end

      def expression_agent
        Home_::Zerk_::API::ArgumentScannerExpressionAgent.instance
      end
    # -
  end
end
