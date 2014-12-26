require_relative '../test-support'

module Skylab::Headless::TestSupport::System::Services

  describe "[hl] system services patch" do

    extend TS_

    it 'loads' do
      patch
    end

    context "changes (\"c\")" do
      it "two non-contiguous single lines" do
        p = patch.new "one\ntwo\nthree"
        p.change_line 1, 'ONE'
        p.change_line 3, 'THREE'
        actual = p.render_simple
        expect = <<-O.unindent
          1c1
          < one
          ---
          > ONE
          3c3
          < three
          ---
          > THREE
        O
        actual.should eql( expect )
      end

      it "at end change one line to two" do
        p = patch.new "one\ntwo"
        p.change_lines 2, ['TWO', 'THREE']
        p.render_simple.should eql( <<-O.unindent )
          2c2,3
          < two
          ---
          > TWO
          > THREE
        O
      end
    end

    context "removes (\"d\")" do
      it "two non-contiguous inner chunks" do
        p = patch.new "one\ntwo\nthree\nfour\nfive\nsix\nseven"
        p.change_lines 2..4, []
        p.change_lines 6, []
        actual = p.render_simple
        expect = <<-O.unindent
          2,4d1
          < two
          < three
          < four
          6d2
          < six
        O
        actual.should eql( expect )
      end

      it "two at beginning" do
        p = patch.new "one\ntwo\nthree"
        p.change_lines 1..2, []
        p.render_simple.should eql( <<-O.unindent )
          1,2d0
          < one
          < two
        O
      end

      it "one at end" do
        p = patch.new "one\ntwo\nthree"
        p.change_lines 3, []
        p.render_simple.should eql( <<-O.unindent )
          3d2
          < three
        O
      end
    end

    context "adds (\"a\")" do
      it "two in middle" do
        p = patch.new "one\ntwo\nfive\nsix"
        p.change_lines 3...3, [ 'three', 'four' ]
        actual = p.render_simple
        expect = <<-O.unindent
          2a3,4
          > three
          > four
        O
        actual.should eql( expect )
      end

      it "one at begin" do
        p = patch.new "two\nthree"
        p.change_lines 1...1, [ 'one' ]
        p.render_simple.should eql( "0a1\n> one\n" )
      end

      it "one at end" do
        p = patch.new "one\ntwo"
        p.change_lines 3...3, [ 'three' ]
        p.render_simple.should eql( "2a3\n> three\n" )
      end
    end

    def patch
      subject.patch
    end
  end
end
