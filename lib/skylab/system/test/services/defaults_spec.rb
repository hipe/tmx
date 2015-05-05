require_relative 'test-support'

module Skylab::Headless::TestSupport::System::Services

  describe "[hl] system services defaults" do

    extend TS_

    it "dev_tmpdir_pathname (memoized)" do
      oid1 = subject.dev_tmpdir_pathname
      oid2 = subject.dev_tmpdir_pathname
      oid1.should eql oid2
    end

    it "dev_tmpdir_path" do
      _build_it_manually = subject.dev_tmpdir_pathname.to_path
      subject.dev_tmpdir_path.should eql _build_it_manually
    end

    it "cache_pathname (#fragile)" do
      subject  # yes
      fn = Subject____[]::Defaults::CACHE_FILE__
      subject.cache_pathname.join( "FOO" ).to_path.
        should be_include( "#{ fn }/FOO" )
    end

    def subject
      super.defaults
    end
  end
end
