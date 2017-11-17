require_relative '../test-support'

module Skylab::CodeMetrics::TestSupport

  describe "[cm] operations - dirs" do

    TS_[ self ]
    use :want_event

    it "ok." do

      call_API :dirs,
        :path, Fixture_tree_directory_[]

      t = @result
      a = t.to_child_stream.to_a
      2 == a.length or fail

      a.map( & :slug ).should eql %w( fixture-files-one fixture-files-two )
      x = a.first
      o = a.last

      x.num_files.should eql 3
      x.num_lines.should eql 12

      o.num_files.should eql 2
      o.num_lines.should eql 3

      # (we are ignoring ~ 6 events)
    end
  end
end
