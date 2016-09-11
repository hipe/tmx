require_relative '../test-support'

module Skylab::Basic::TestSupport

  describe "[ba] string - line scanner" do

    extend TS_
    use :string

    it "loads" do
      subject
    end

    it "when built with a string, works the same" do  # mirror 2 others
      scn = of "one C\ntwo C\n"
      scn.lineno.should be_zero  # be like ::File
      scn.gets.should eql "one C\n"
      scn.lineno.should eql 1
      scn.gets.should eql "two C\n"
      scn.lineno.should eql 2
      scn.gets.should be_nil
      scn.lineno.should eql 2
      scn.gets.should be_nil
    end

    it "empty string" do
      scn = of ''
      scn.lineno.should be_zero
      scn.gets.should be_nil
      scn.lineno.should be_zero
      scn.gets.should be_nil
    end

    it "noneempty string no terminating newline" do
      scn = of 'abc'
      scn.lineno.should be_zero
      scn.gets.should eql 'abc'
      scn.lineno.should eql 1
      scn.gets.should be_nil
      scn.lineno.should eql 1
    end

    it "nonempty string terminating newline" do
      scn = of "foo\n"
      scn.lineno.should be_zero
      scn.gets.should eql "foo\n"
      scn.lineno.should eql 1
      scn.gets.should be_nil
      scn.lineno.should eql 1
    end

    it "two no term" do
      scn = of "foo\nbar"
      scn.lineno.should be_zero
      scn.gets.should eql "foo\n"
      scn.lineno.should eql 1
      scn.gets.should eql "bar"
      scn.lineno.should eql 2
      scn.gets.should be_nil
      scn.lineno.should eql 2
      scn.gets.should be_nil
      scn.lineno.should eql 2
    end

    it "two term" do
      scn = of "foo\nbar\n"
      scn.gets.should eql "foo\n"
      scn.gets.should eql "bar\n"
      scn.gets.should be_nil
    end

    it "three with interceding blank line" do
      scn = of "foo\n\nbar\n"
      scn.gets.should eql "foo\n"
      scn.gets.should eql "\n"
      scn.lineno.should eql 2
      scn.gets.should eql "bar\n"
      scn.lineno.should eql 3
    end

    it "reverse" do
      str = "haha\n"
      y = subject.reverse str
      y << 'this'
      y << 'is what'
      str.should eql "haha\nthis\nis what"
    end

    def subject( * a )
      if a.length.zero?
        subject_module_.line_stream
      else
        subject_module_.line_stream( * a )
      end
    end

    alias_method :of, :subject
  end
end
