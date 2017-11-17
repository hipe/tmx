require_relative '../../test-support'

module Skylab::Zerk::TestSupport

  describe "[ze] CLI (test test) - want section fail early (inspired by OGDL)" do

    TS_[ self ]
    use :memoizer_methods

    subject = nil

    it "loads" do
      subject[]
    end

    context "with a two-node snowman" do

      it "the structure parses" do
        _tree or fail
      end

      it "the root knows it has an only child" do

        _tree.only_child or fail
      end

      it "this only child knows its own line (with newline)" do

        _tree.only_child.x.string.should eql "aaa\n"
      end

      it "both root and \"top\" know their children length" do

        root = _tree
        root.children.length.should eql 1

        _top = root.only_child
        _top.children.length.should eql 1
      end

      it "`line_content` omits any newline" do

        _some_node.x.line_content.should eql 'bbb'
      end

      it "the internal line structure preserves channel" do

        _some_node.x.stream_symbol.should eql :_no_stream_
      end

      shared_subject :_some_node do
        _tree.only_child.only_child
      end

      memoize :_tree do

        _ = <<-HERE.unindent
          aaa
            bbb
        HERE

        subject[].tree_via :string, _
      end
    end

    context "with a deeper but well formed tree" do

      it "ok." do
        root.children.map { | cx | cx.x.line_content }.should eql(
          [ 'head', 'torso', 'legs' ] )
      end

      memoize :root do

        _ = <<-HERE.unindent
          head
            mouth
          torso
            trunk
            pelvis
              tailbone
          legs
        HERE

        subject[].tree_via :string, _
      end
    end

    def section
      top.only_child
    end

    def top
      root.only_child
    end

    subject = Lazy_.call do
      TS_::CLI::Want_Section_Fail_Early
    end
  end
end
