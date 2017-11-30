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

      expect( a.map( & :slug ) ).to eql %w( fixture-files-one fixture-files-two )
      x = a.first
      o = a.last

      expect( x.num_files ).to eql 3
      expect( x.num_lines ).to eql 12

      expect( o.num_files ).to eql 2
      expect( o.num_lines ).to eql 3

      # (we are ignoring ~ 6 events)
    end
  end
end
