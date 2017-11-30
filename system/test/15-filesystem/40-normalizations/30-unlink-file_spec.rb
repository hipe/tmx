require_relative '../../test-support'

module Skylab::System::TestSupport

  describe "[sy] filesystem - n11ns - unlink file" do

    TS_[ self ]
    use :filesystem_normalizations

    it "no exist" do

      begin
        against_ TestSupport_::Fixtures.file :not_here
      rescue ::Errno::ENOENT => e
      end

      expect( e.message ).to match %r(\ANo such file or directory )
    end

    it "`probably_exists`" do

      _path = TestSupport_::Fixtures.file :not_here

      @result = subject_via_plus_real_filesystem_plus_listener_(
        :path, _path,
        :probably_exists,
      )

      want_not_OK_event :errno_enoent
      want_fail
    end

    it "do it" do

      td = memoized_tmpdir_.clear
      pn = td.touch 'hi.txt'
      path = pn.to_path

      against_ path
      expect( @result ).to eql true
      want_no_more_events
    end

    def subject_
      Home_::Filesystem::Normalizations::UnlinkFile
    end
  end
end
