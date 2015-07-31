require_relative '../../../test-support'

module Skylab::Callback::TestSupport

  describe "[ca] [..] viz" do

    extend TS_
    TS_::Expect_Event[ self ]

    it "with the ideal case - works" do

      io =  TestSupport_::Library_::StringIO.new
      _path = ::File.join( Home_.dir_pathname.to_path, 'core.rb' )

      call_API(
        :viz,
        :stdout, io,
        :file, _path,
        :const, "#{ TS_.name }::Fixtures::WhoHah",
      )

      io.string.should eql <<-HERE.unindent
        digraph {
          node [shape="Mrecord"]
          label="event stream graph for ::Skylab::Callback::TestSupport::Fixtures::WhoHah"
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
