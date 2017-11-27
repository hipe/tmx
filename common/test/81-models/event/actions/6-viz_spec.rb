require_relative '../../../test-support'

module Skylab::Common::TestSupport

  describe "[co] [..] viz" do

    TS_[ self ]
    use :want_emission

    it "with the ideal case - works" do

      io = String_IO_[].new
      _path = Home_.dir_path

      call_API(
        :viz,
        :stdout, io,
        :file, _path,
        :const, "#{ TS_.name }::FixtureFiles::WhoHah",
      )

      expect( io.string ).to eql <<-HERE.unindent
        digraph {
          node [shape="Mrecord"]
          label="event stream graph for ::Skylab::Common::TestSupport::FixtureFiles::WhoHah"
          hacking -> business
          hacking -> pleasure
        }
      HERE

      want_succeed
    end

    def subject_API
      Home_::CLI.application_kernel_
    end
  end
end
