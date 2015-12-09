require_relative '../test-support'

module Skylab::CodeMetrics::TestSupport

  describe "[cm] models - 1. line count" do

    TS_[ self ]
    use :expect_event

    it "ping" do

      call_API :ping
      expect_neutral_event :ping, "hello from code metrics."
      expect_no_more_events
      @result.should eql :hello_from_code_metrics
    end

    it "noent" do

      call_API :line_count, :path, [ Fixture_file_[ "not-there.code" ] ]
      expect_not_OK_event :enoent, /\ANo such file or directory - /
      expect_no_more_events
      @result.should eql nil
    end

    it "against one directory with a name constraint" do

      call_API :line_count, * _same

      _conj = _expect_these_events
      y = _conj.linecount_NLP_frame.express_into_line_context( [] )

      y.should eql [ 'including blank lines and comment lines' ]

      expect_neutral_event :wc_command
      expect_no_more_events

      totes = @result
      totes.count.should eql 9
      totes.finish

      a = totes.to_child_stream.to_a
      2 == a.length or fail
      x = a.fetch 0
      o = a.fetch 1

      x.count.should eql 6

      ::File.basename( o.slug ).should eql 'some more.code'

      ( 0.65 .. 0.67 ).should be_include x.total_share
      ( 0.32 .. 0.34 ).should be_include o.total_share

      ( 0.99 .. 1.01 ).should be_include x.normal_share
      ( 0.49 .. 0.51 ).should be_include o.normal_share

    end

    it "same as above but skip blank lines and comment lines" do

      call_API :line_count, * _same,
        :without_comment_lines,
        :without_blank_lines

      _conj = _expect_these_events

      y = _conj.linecount_NLP_frame.express_into_line_context []

      y.should eql [ 'excluding blank lines and comment lines' ]

      expect_neutral_event :wc_pipey_command_string
      expect_neutral_event :wc_pipey_command_string

      totes = @result
      totes.count.should eql 4
    end

    def _same
      [ :path, [ Fixture_file_directory_[] ], :include_name, [ '*.code' ] ]
    end

    def _expect_these_events

      expect_neutral_event :find_command_args
      expect_neutral_event :file_list
      expect_neutral_event :linecount_NLP_frame

    end
  end
end
