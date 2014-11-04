require_relative 'test-support'

module Skylab::Brazen::TestSupport::Data_Stores_::Git_Config

  describe "[br] data stores - git config - write" do

    extend TS_

    it "an easy way to write a single-section config" do
      td = prepared_tmpdir
      pn = td.join 'some-file.cfg'
      io = ::File.open pn.to_path, 'w+'
      a = []
      a.push Callback_.pair.new 'x x', :Foo
      a.push Callback_.pair.new true, :zappo
      _scn = Callback_.scan.via_nonsparse_array a
      _x = parent_subject.cfg.write io, _scn, 'sub sec.to', 'se-cto'
      io.rewind
      s = io.read
      io.close
      s.should eql <<-O.gsub %r(^[ ]+), Brazen_::EMPTY_S_
        [se-cto "sub sec.to"]
        Foo = x x
        zappo = true
      O
    end

    def parent_subject
      Brazen_
    end
  end
end
