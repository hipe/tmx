require_relative '../test-support'

module Skylab::Task::TestSupport

  describe "[ta] magnetics - CLI", wip: true do

    TS_[ self ]
    use :magnetics_CLI

    context "schlum schlum" do

      given do
        argv 'magnetics-vis', 'shlum-shlum'
      end

      it "the output looks like a digraph (outer lines)" do
        a = niCLI_state.lines
        a.first.string == "digraph g {\n" or fail
        a.last.string == "}\n" or fail
      end

      it "waypoint assoc" do
        _at( 1 ) == "  hover_craft -> hover_craft_0\n" or fail
      end

      it "means component assoc" do
        _at( 3 ) == "  hover_craft_0 -> amazon\n"
      end

      it "blank line" do
        _at( 6 ) == "\n" or fail
      end

      it "waypoint head label" do
        _at( 7 ) == "  hover_craft [label=\"hover-craft\"]\n"
      end

      it "means head label" do
        _at( 8 ) == "  hover_craft_0 [label=\"(0)\"]\n"
      end

      def _at d
        niCLI_state.lines.fetch( d ).string
      end

      def for_expect_stdout_stderr_prepare_invocation invo

        fs = begin_mock_FS_
        fs.add_thing 'shlum-shlum' do
          %w( . ..
            hover-craft-via-amazon.rx
            hover-craft-via-cunning-and-ingenuity.rx )
        end
        invo.filesystem = fs.finish
      end
    end
  end
end
