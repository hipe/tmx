require_relative '../test-support'

module Skylab::CodeMetrics::TestSupport

  describe "[cm] operations - ext" do

    TS_[ self ]
    use :expect_event

    it "ok." do

      call_API :ext,
        :path, [ Fixture_file_directory_[] ]

      expect_neutral_event :find_files_command

      a = @result.to_child_stream.to_a
      2 == a.length or fail
      x = a.first
      o = a.last
      x.slug.should eql '*.code'
      x.count.should eql 2

      o.slug.should eql '*.file'
      o.count.should eql 1

    end
  end
end
