require_relative '../../test-support'

module Skylab::BeautySalon::TestSupport::Models::S_and_R::Actors_BFS

  describe "[bs] models - S & R - models - multi-line edit file session" do

    extend TS_

    it "when the filesize is under the limit - OK" do

      file_session_scan = Subject_[].with :upstream_path_scan,
        build_scan_for_single_path_to_file_with_three_lines,
        :ruby_regexp, /e[\n!]/m,
        :for_interactive_search_and_replace

      scan = file_session_scan
      file = scan.gets
      scan.gets.should be_nil

      d = file.match_count
      d.should eql 3

      # etc ..
    end
  end
end
