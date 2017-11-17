module Skylab::CodeMetrics

  module Home_::Model_::Support

    class Models_::Ping < Report_Action

      # set :node, :ping, :invisible  # #[#br-095]

      def produce_result

        @listener.call :info, :expression, :ping do | y |
          y << "hello from code metrics."
        end
        :hello_from_code_metrics
      end
    end
  end
end
