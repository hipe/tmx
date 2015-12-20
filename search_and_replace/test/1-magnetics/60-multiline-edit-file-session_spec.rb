require_relative '../test-support'

module Skylab::SearchAndReplace::TestSupport

  describe "[se] models - S & R - models - multi-line edit file session", wip: true do

    TS_[ self ]
    use :expect_event
    use :magnetics_file_stream

    it "when the filesize is under the limit - OK" do

      file_session_stream = actors_::Build_file_stream.with :upstream_path_stream,
        build_stream_for_single_path_to_file_with_three_lines_,
        :ruby_regexp, /e[\n!]/m,
        :for_interactive_search_and_replace

      stream = file_session_stream
      file = stream.gets
      stream.gets.should be_nil

      d = file.match_count
      d.should eql 3

      # etc ..
    end
  end
end
