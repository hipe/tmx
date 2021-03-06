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

        run_the_tests_thru_a_CLI_expecting_everything_on_STDOUT_ do |o|
          o.receive_test_support_module_by = method :__receive_test_support_module
          o.want_lines_by = method :__want_these_lines
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

      def __want_these_lines o
        o.want                "desc 1"
        o.want                "  ctxt 1"
        o.want_styled_content "    eg 1", :green
        want_finished_line_ o
        o.want_styled_content "1 example, 0 failures", :green
      end
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
