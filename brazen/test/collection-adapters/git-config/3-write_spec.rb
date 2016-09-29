require_relative '../../test-support'

module Skylab::Brazen::TestSupport

  describe "[br] collection adapters - git config - write" do

    TS_[ self ]
    use :collection_adapters_git_config

    it "an easy way to write a single-section config" do
      td = prepared_tmpdir
      pn = td.join 'some-file.cfg'
      io = ::File.open pn.to_path, 'w+'
      a = []
      a.push Common_::Pair.via_value_and_name( 'x x', :Foo )
      a.push Common_::Pair.via_value_and_name( true, :zappo )
      _scan = Common_::Stream.via_nonsparse_array a
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
      _a = [ Common_::Pair.via_value_and_name( '\b', :'two-characters' ) ]
      _scan = Common_::Stream.via_nonsparse_array _a
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

      _head = Home_::TestSupport::Fixtures.dir_path
      _cfg_path = ::File.join _head, '00-escape.cfg'

      doc = subject.parse_path _cfg_path
      sect = doc.sections.first
      ast = sect.assignments.first
      ast.value_x.should eql '\\b'
    end
  end
end
