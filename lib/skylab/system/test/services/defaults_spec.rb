require_relative '../test-support'

module Skylab::System::TestSupport

  describe "[sy] services - defaults" do

    extend TS_

    it "dev_tmpdir_pathname (memoized)" do

      oid1 = _subject.dev_tmpdir_pathname
      oid2 = _subject.dev_tmpdir_pathname
      oid1.should eql oid2
    end

    it "dev_tmpdir_path" do

      _build_it_manually = _subject.dev_tmpdir_pathname.to_path
      _subject.dev_tmpdir_path.should eql _build_it_manually
    end

    it "cache_pathname (#fragile)" do

      _subject  # sic

      _fn = System_::Services___::Defaults::CACHE_FILE__

      _subject.cache_pathname.join( "FOO" ).to_path.
        should be_include( "#{ _fn }/FOO" )
    end

    def _subject
      services_.defaults
    end
  end
end
