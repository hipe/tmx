require_relative '../test-support'

module Skylab::Task::TestSupport

  describe "[ta] magnetics-viz - CLI integration" do

    TS_[ self ]
    use :mag_viz_CLI  # [ze] non_interactive_CLI

    context "schlum schlum" do

      given do
        argv 'magnetics-vis', 'shlum-shlum'
      end

      it "the output looks like a digraph" do
        a = niCLI_state.lines
        a.first.string == "digraph g {\n" or fail
        a.last.string == "}\n" or fail
      end

      def for_expect_stdout_stderr_prepare_invocation invo
        invo.filesystem = :SOMETHING
      end
    end
  end
end
