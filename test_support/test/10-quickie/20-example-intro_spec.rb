require_relative '../test-support'

module Skylab::TestSupport::TestSupport

  describe "[ts] quickie - example intro" do

    TS_[ self ]
    use :memoizer_methods
    use :quickie

    context "one context with one example, no tests" do

      it "output is as expected, line-by-line" do
        _state || fail
      end

      it "ran the example (once)" do
        _state == [ :_ran_it_ ] || fail
      end

      shared_subject :_state do

        run_the_tests_thru_a_CLI_expecting_a_single_stream_by__ do |o|
          o.receive_test_support_module_by = method :__receive_test_support_module
          o.expect_lines_by = method :__expect_these_lines
        end
      end

      def __receive_test_support_module mod

        a = []
        mod.describe "desc 1" do

          context "ctxt 1" do

            it "eg 1" do
              a.push :_ran_it_
            end
          end
        end
        a
      end

      def __expect_these_lines o
        o.expect                "desc 1"
        o.expect                "  ctxt 1"
        o.expect_styled :green, "    eg 1"
        _expect_finished_line o
        o.expect_styled :green, "1 example, 0 failures"
      end
    end

    def _expect_finished_line o
      o.expect %r(\A\nFinished in \d+(?:\.\d+)? seconds?\z)
    end

    # ==

    def ARGV_
      EMPTY_A_
    end

    def toplevel_module_
      toplevel_module_with_rspec_not_loaded_
    end

    def kernel_module_
      kernel_module_with_rspec_not_loaded_
    end

    # ==
  end
end
# #born: years later
