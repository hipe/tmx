require_relative '../test-support'

module Skylab::SearchAndReplace::TestSupport

  describe "[sa] magnetics - (32) replacement adds lines", wip: true do

    TS_[ self ]
    use :memoizer_methods
    use :magnetics_mutable_file_session

    # - performance

      it "in repl string you can add lines that weren't there and opposite" do

        _input = unindent_ <<-HERE
          one
          two
          three
        HERE

        es = build_edit_session_via_ _input, /(?:thre)?e\n/
        _mc1 = es.first_match_controller
        _mc2 = _mc1.next_match_controller

        _mc1.engage_replacement_via_string "iguruma\nand PCRE are\n"
        _mc2.engage_replacement_via_string "rx engines"

        st = es.to_line_stream
        st.gets.should eql "oniguruma\n"
        st.gets.should eql "and PCRE are\n"
        st.gets.should eql "two\n"
        st.gets.should eql "rx engines"
        st.gets.should be_nil
      end
    # -
  end
end
