require_relative '../test-support'

module Skylab::SearchAndReplace::TestSupport

  describe "[se] models - S & R - models - multi-line edit file session" do

    TS_[ self ]
    use :expect_event
    use :magnetics_file_stream

    it "when the filesize is under the limit - OK" do

      _st = build_stream_for_single_path_to_file_with_three_lines_

      file_session_stream = magnetics_::File_Session_Stream_via_Parameters.with(
        :upstream_path_stream, _st,
        :ruby_regexp, /e[\n!]/m,
        :for_interactive_search_and_replace,
      )

      st = file_session_stream
      file = st.gets
      st.gets.should be_nil

      _d = file.match_count
      _d.should eql 3

      # etc ..
    end
  end
end
