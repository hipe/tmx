require_relative '../test-support'

module Skylab::System::TestSupport

  describe "[sy] IO - line scanner" do

    TS_[ self ]
    use :IO_line_scanner

    context "normal case" do

      it "when built with pathname - `gets` - works as expected" do  # mirror 2 others
        scn = subject_via_pathname pathname
        expect( scn.lineno ).to be_nil
        _ = scn.gets
        expect( _ ).to eql "one\n"
        expect( scn.lineno ).to eql 1
        expect( scn.gets ).to eql "two\n"
        expect( scn.lineno ).to eql 2
        expect( scn.fh.closed? ).to eql false
        expect( scn.gets ).to be_nil
        expect( scn.lineno ).to eql 2
        expect( scn.gets ).to be_nil
        expect( scn.fh ).to be_closed
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
        expect( scn.gets ).to eql "abc\n"
        expect( scn.lineno ).to eql 1
        expect( scn.gets ).to eql "def\n"
        expect( scn.lineno ).to eql 2
        expect( scn.gets ).to eql "ghi\n"
        expect( scn.lineno ).to eql 3
        expect( scn.gets ).to eql nil
        expect( scn.lineno ).to eql 3
        expect( scn.gets ).to eql nil
        expect( scn.lineno ).to eql 3
        expect( fh ).to be_closed
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
        expect( scn.lineno ).to be_nil
        expect( scn.count ).to be_zero
        _ = scn.gets
        expect( _ ).to eql _STR
        expect( scn.count ).to eql 0  # NOTE
        expect( scn.lineno ).to be_nil
        expect( scn.gets ).to be_nil
        expect( scn.lineno ).to be_nil
      end
    end

    context "empty file" do

      with "empty-lsfr.txt" do |o|
      end

      it "hi" do
        scn = subject_via_pathname pathname
        expect( scn.fh.closed? ).to eql false
        expect( scn.count ).to be_zero
        _ = scn.gets
        expect( _ ).to be_nil
        expect( scn.fh.closed? ).to eql true
        expect( scn.count ).to be_zero
      end
    end
  end
end
