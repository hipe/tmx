require_relative '../test-support'

module Skylab::CodeMetrics::TestSupport

  describe "[cm] operations - line count" do

    TS_[ self ]
    use :want_event

    it "ping" do

      call_API :ping
      want_neutral_event :ping, "hello from code metrics."
      want_no_more_events
      expect( @result ).to eql :hello_from_code_metrics
    end

    it "noent" do

      call_API :line_count, :path, [ Fixture_file_[ "not-there.code" ] ]
      want_not_OK_event :enoent, /\ANo such file or directory - /
      want_no_more_events
      expect( @result ).to eql nil
    end

    it "against one directory with a name constraint" do

      call_API :line_count, * _same

      _linecount_NLP_frame = _want_these_events

      y = _linecount_NLP_frame.express_into_line_context( [] )

      expect( y ).to eql [ 'including blank lines and comment lines' ]

      want_freeform_event :wc_command
      want_no_more_events

      totes = @result
      expect( totes.count ).to eql 9
      totes.finish

      a = totes.to_child_stream.to_a
      2 == a.length or fail
      x = a.fetch 0
      o = a.fetch 1

      expect( x.count ).to eql 6

      expect( ::File.basename o.slug ).to eql 'some more.code'

      expect( 0.65 .. 0.67 ).to be_include x.total_share
      expect( 0.32 .. 0.34 ).to be_include o.total_share

      expect( 0.99 .. 1.01 ).to be_include x.normal_share
      expect( 0.49 .. 0.51 ).to be_include o.normal_share

    end

    it "same as above but skip blank lines and comment lines" do

      call_API :line_count, * _same,
        :without_comment_lines,
        :without_blank_lines

      _linecount_NLP_frame = _want_these_events

      y = _linecount_NLP_frame.express_into_line_context []

      expect( y ).to eql [ 'excluding blank lines and comment lines' ]

      want_freeform_event :wc_pipey_command_string
      want_freeform_event :wc_pipey_command_string

      totes = @result
      expect( totes.count ).to eql 4
    end

    def _same
      [ :path, [ Fixture_file_directory_[] ], :include_name, [ '*.code' ] ]
    end

    def _want_these_events

      want_neutral_event :line_count_command

      want_freeform_event :file_list

      _em = want_freeform_event :linecount_NLP_frame

      _em.cached_event_value
    end
  end
end
