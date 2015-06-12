require_relative '../test-support'

module Skylab::FileMetrics::TestSupport

  describe "[fm] models - 3. ext" do

    extend TS_
    use :expect_event

    it "ok." do

      call_API :ext,
        :path, [ Fixture_file_directory_[] ]

      expect_neutral_event :find_command_args

      a = @result.children
      2 == a.length or fail
      x = a.first
      o = a.last
      x.label.should eql '*.code'
      x.count.should eql 2

      o.label.should eql '*.file'
      o.count.should eql 1

    end
  end
end
