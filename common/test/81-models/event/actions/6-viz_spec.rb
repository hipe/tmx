require_relative '../../../test-support'

module Skylab::Common::TestSupport

  describe "[co] [..] viz" do

    TS_[ self ]
    use :expect_event

    it "with the ideal case - works" do

      io =  TestSupport_::Library_::StringIO.new
      _path = Home_.dir_path

      call_API(
        :viz,
        :stdout, io,
        :file, _path,
        :const, "#{ TS_.name }::FixtureFiles::WhoHah",
      )

      io.string.should eql <<-HERE.unindent
        digraph {
          node [shape="Mrecord"]
          label="event stream graph for ::Skylab::Common::TestSupport::FixtureFiles::WhoHah"
          hacking -> business
          hacking -> pleasure
        }
      HERE

      expect_succeeded
    end

    def subject_API
      Home_::CLI._application_kernel
    end
  end
end