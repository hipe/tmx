require_relative '../../../test-support'

module Skylab::System::TestSupport

  describe "[sy] services - filesystem - n11ns - unlink file" do

    extend TS_
    use :services_filesystem_normalizations_support

    it "no exist" do

      begin
        against_ TestSupport_::Fixtures.file( :not_here )
      rescue ::Errno::ENOENT => e
      end

      e.message.should match %r(\ANo such file or directory )
    end

    it "`probably_exists`" do

      _path = TestSupport_::Fixtures.file( :not_here )

      @result = subject_.with(

        :path, _path,
        :probably_exists,
        & handle_event_selectively
      )

      expect_not_OK_event :errno_enoent
      expect_failed
    end

    it "do it" do

      td = memoized_tmpdir_.clear
      pn = td.touch 'hi.txt'
      path = pn.to_path

      against_ path
      @result.should eql true
      expect_no_more_events
    end

    def subject_
      Home_.services.filesystem :Unlink_File
    end
  end
end
