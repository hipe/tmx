require_relative 'test-support'

module Skylab::Brazen::TestSupport::Collection_Adapters::Git_Config

  describe "[br] collection adapters - git config - write" do

    extend TS_

    it "an easy way to write a single-section config" do
      td = prepared_tmpdir
      pn = td.join 'some-file.cfg'
      io = ::File.open pn.to_path, 'w+'
      a = []
      a.push Callback_::Pair[ 'x x', :Foo ]
      a.push Callback_::Pair[ true, :zappo ]
      _scan = Callback_::Stream.via_nonsparse_array a
      x = subject.write io, _scan, 'sub sec.to', 'se-cto'
      x.should eql true
      io.rewind
      s = io.read
      io.close
      s.should eql <<-O.gsub %r(^[ ]+), Home_::EMPTY_S_
        [se-cto "sub sec.to"]
        Foo = x x
        zappo = true
      O
    end

    it "don't fall over on backslashes" do
      _a = [ Callback_::Pair[ '\b', :'two-characters' ] ]
      _scan = Callback_::Stream.via_nonsparse_array _a
      io = Home_::LIB_.string_IO.new
      x = subject.write io, _scan, 'sub.sect', 'se-ct'
      x.should eql true
      s = io.string
      lines = s.split Home_::NEWLINE_
      lines.last.should eql 'two-characters = \\\\b'  # the value that was
      # input as two characters (the backslash character then the 'b' character)
      # became three: a backslash, a backslash, 'b'
    end

    it "gets back up with backslashes" do

      _cfg_path = Home_::TestSupport::Fixtures.dir_pathname.join( '00-escape.cfg' ).to_path

      doc = Subject_[].parse_path _cfg_path
      sect = doc.sections.first
      ast = sect.assignments.first
      ast.value_x.should eql '\\b'

    end

    def subject
      Home_.cfg
    end
  end
end
