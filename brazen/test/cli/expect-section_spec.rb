require_relative 'test-support'

module Skylab::Brazen::TestSupport::CLI

  describe "[br] CLI - expect section (inspired by OGDL)" do

    subject = nil

    context "with a two-node snowman" do

      it ".children, .x.line, .x.line_content" do

        top = root.only_child
        top.x.line.should eql "aaa\n"
        top.children.length.should eql 1
        top.only_child.x.line_content.should eql 'bbb'
      end

      define_method :root, ( Callback_.memoize do
        subject[].tree_via_string <<-HERE.unindent
          aaa
            bbb
        HERE
      end )
    end

    context "with a deeper but well formed tree" do

      it "ok." do
        root.children.map { | cx | cx.x.line_content }.should eql(
          [ 'head', 'torso', 'legs' ] )
      end

      define_method :root, ( Callback_.memoize do
        subject[].tree_via_string <<-HERE.unindent
          head
            mouth
          torso
            trunk
            pelvis
              tailbone
          legs
        HERE
      end )
    end

    def section
      top.only_child
    end

    def top
      root.only_child
    end

    subject = -> do
      TS_::Expect_Section
    end
  end
end
