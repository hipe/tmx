module Skylab::GitViz

  module TestSupport::Test_Lib_::Mock_System

    class Server_Expect
      def self.[] ctx
        ctx.include Methods__ ; nil
      end

      module Methods__

        def expect * chan_i_a
          2 == chan_i_a.length and rx = chan_i_a.pop
          row = @response.gets_statement_string_a
          row or fail "expected API response statement, had none."
          actual_channel_i_a = row[ 0 .. chan_i_a.length - 1 ]
          actual_channel_i_a.should eql chan_i_a
          if rx
            row.last.should match rx
          end
        end

        def expect_no_more_server_statements
          @response.statement_count.should be_zero
        end

        def expect_stderr rx
          s = @stderr_lines.shift
          s or fail "expected stderr line, had none"
          s.should match rx
        end

        def expect_no_more_stderr_lines
          @stderr_lines.length.should be_zero
        end

        def expect_errored cod=nil
          expect_no_more_server_statements
          expect_no_more_stderr_lines
          if cod
            expect_response_result_code cod
          else
            expect_response_result_code_for_general_error
          end
        end

        def expect_response_result_code_for_general_error
          expect_response_result_code( GitViz_::Test_Lib_::
            Mock_System::Fixture_Server::GENERAL_ERROR_ )
        end

        def expect_response_result_code d
          @response.result_code.should eql d
        end
      end
    end
  end
end
