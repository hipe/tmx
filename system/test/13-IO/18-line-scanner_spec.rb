require_relative '../test-support'

module Skylab::System::TestSupport

  describe "[sy] IO - line scanner" do

    TS_[ self ]
    use :IO_line_scanner

    context "normal case" do

      it "when built with pathname - `gets` - works as expected" do  # mirror 2 others
        scn = subject_via_pathname pathname
        scn.lineno.should be_nil
        _ = scn.gets
        _.should eql "one\n"
        scn.lineno.should eql 1
        scn.gets.should eql "two\n"
        scn.lineno.should eql 2
        scn.fh.closed?.should eql false
        scn.gets.should be_nil
        scn.lineno.should eql 2
        scn.gets.should be_nil
        scn.fh.should be_closed
      end

      with 'foo-lsfr.txt' do |o|
        o << <<-O.unindent
          one
          two
        O
      end
    end

    context "if the page break happens mid-line" do

      it "o" do
        fh = pathname.open 'r'
        scn = subject_via_filehandle fh, 5
        scn.gets.should eql "abc\n"
        scn.lineno.should eql 1
        scn.gets.should eql "def\n"
        scn.lineno.should eql 2
        scn.gets.should eql "ghi\n"
        scn.lineno.should eql 3
        scn.gets.should eql nil
        scn.lineno.should eql 3
        scn.gets.should eql nil
        scn.lineno.should eql 3
        fh.should be_closed
      end

      with "bar-lsfr.txt" do |o|
        o << <<-O.unindent
          abc
          def
          ghi
        O
      end
    end

    context "file with no newline NOTE we use the `wc` definition of line!" do  # :+[#sg-020]

      _STR = 'there is no newline at the end of this line'.freeze

      with "no-newline-lsfr.txt" do |o|
        o << _STR ; nil
      end

      it "o" do
        scn = subject_via_pathname pathname
        shared_expectation scn
      end

      it "when page size is shorter than record - o" do
        scn = subject_via_pathname pathname, _STR.length - 1
        shared_expectation scn
      end

      it "when page size equals record size - o " do
        scn = subject_via_pathname pathname, _STR.length
        shared_expectation scn
      end

      define_method :shared_expectation do |scn|
        scn.lineno.should be_nil
        scn.count.should be_zero
        _ = scn.gets
        _.should eql _STR
        scn.count.should eql 0  # NOTE
        scn.lineno.should be_nil
        scn.gets.should be_nil
        scn.lineno.should be_nil
      end
    end

    context "empty file" do

      with "empty-lsfr.txt" do |o|
      end

      it "hi" do
        scn = subject_via_pathname pathname
        scn.fh.closed?.should eql false
        scn.count.should be_zero
        _ = scn.gets
        _.should be_nil
        scn.fh.closed?.should eql true
        scn.count.should be_zero
      end
    end
  end
end