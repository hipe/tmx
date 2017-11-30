require_relative '../test-support'

module Skylab::CodeMetrics::TestSupport

  describe "[cm] operations - ext" do

    TS_[ self ]
    use :want_event

    it "ok." do

      call_API :ext,
        :path, [ Fixture_file_directory_[] ]

      want_neutral_event :find_files_command

      a = @result.to_child_stream.to_a
      2 == a.length or fail
      x = a.first
      o = a.last
      expect( x.slug ).to eql '*.code'
      expect( x.count ).to eql 2

      expect( o.slug ).to eql '*.file'
      expect( o.count ).to eql 1

    end
  end
end
