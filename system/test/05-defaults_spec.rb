require_relative 'test-support'

module Skylab::System::TestSupport

  describe "[sy] defaults" do

    TS_[ self ]

    it "dev_tmpdir_path is trueish" do

      _subject.dev_tmpdir_path or fail
    end

    it "dev_tmpdir_path is memoized" do

      p1 = _subject.dev_tmpdir_path
      p2 = _subject.dev_tmpdir_path
      expect( p1.object_id ).to eql p2.object_id
    end

    it "cache_path (#fragile)" do

      path = _subject.cache_path

      foo = "FOO"

      _target = ::File.join(
        Home_::Defaults::Service::CACHE_FILE__,
        foo
      )
      _actual = ::File.join path, foo

      expect( _actual ).to be_include _target
    end

    def _subject
      services_.defaults
    end
  end
end
