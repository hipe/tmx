require_relative '../test-support'

module Skylab::TanMan::TestSupport::Models::Scan__

  ::Skylab::TanMan::TestSupport::Models[ TS__ = self ]

  include Constants

  extend TestSupport_::Quickie

  TanMan_ = TanMan_

  module ModuleMethods
    def use _METH_I_
      define_method :use_method do _METH_I_ end
    end
  end

  module InstanceMethods
    def with s
      @s = s
    end
    def expect * s_a
      _subject = TanMan_::Models_::Comment::Line_Stream
      scn = _subject.send use_method, @s
      a = []
      while s = scn.gets
        a.push s
      end
      a.should eql s_a ; nil
    end
  end

  describe "[tm] comment stream" do

    extend TS__

    context "ordinary strings" do

      it "the empty string is NO lines" do
        with EMPTY_S_
        expect
      end

      it "a single newline is ONE line" do
        with NEWLINE_
        expect EMPTY_S_
      end

      it "one line" do
        with "ohai\n"
        expect 'ohai'
      end

      it "two lines" do
        with "foo\nbar"
        expect 'foo', 'bar'
      end

      it "interceding blank lines are still there" do
        with "a\n\nc"
        expect 'a', EMPTY_S_, 'c'
      end

      use :of_string
    end


    context "shell style" do

      it "one line" do
        with "  # zanger \n"
        expect ' zanger '
      end

      it "two lines" do
        with " # feeple\n#deeple"
        expect ' feeple', 'deeple'
      end

      use :of_comment_string
    end

    context "c-style" do

      it "one line" do
        with '/*ha*/'
        expect 'ha'
      end

      it "two lines" do
        with "   /*  one\ntwo */  "
        expect '  one', 'two '
      end

      use :of_comment_string
    end
  end
end
