require_relative '../test-support'

module Skylab::BeautySalon::TestSupport::Models::S_and_R::Actors_BFS

  describe "[bs] models - S & R - models - read only file session " do

    extend TS_

    it "BFS loads" do
      Subject_[]
    end

    it "normal - (unlike grep it only highlights the first match on a given single line" do

      file_session_scan = Subject_[].with :upstream_path_scan,
        build_scan_for_single_path_to_file_with_three_lines,
        :ruby_regexp, /\bwazoozle\b/i,
        :read_only

      one_file = file_session_scan.gets
      file_session_scan.gets.should be_nil

      scn = one_file.to_read_only_match_scan
      first = scn.gets
      last = scn.gets
      scn.gets.should be_nil
      first.line_number.should eql 1
      last.line_number.should eql 3

      line = last.render_highlighted_line
      _styled_rest = /\A[^:]+:[^:]+:(.+)\z/m.match( line )[ 1 ]
      _omg = BS_._lib.CLI_lib.parse_styles _styled_rest
      _omg.map( & :first ).
        should eql [ :string, :style, :string, :style, :string ]
          # (opening and closing style spans. means one styled item

    end
  end
end
