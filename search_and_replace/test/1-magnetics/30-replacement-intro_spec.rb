require_relative '../test-support'

module Skylab::SearchAndReplace::TestSupport

  describe "[sa] magnetics - (30) replacement intro" do

    TS_[ self ]
    use :memoizer_methods
    use :magnetics_mutable_file_session

    it "minimal performance" do

      es = build_edit_session_via_ 'a', /a/

      _mc = es.first_match_controller

      _ = _mc.engage_replacement_via_string 'b'

      _.should be_nil

      st = es.to_line_stream

      _ = st.gets
      _.should eql 'b'
      _ = st.gets
      _.should be_nil
    end

    it "replace the first of two" do

      es = build_edit_session_via_ "GAK and GAK\n", /\bgak\b/i
      _mc = es.first_match_controller
      _mc.engage_replacement_via_string 'wak'

      st = es.to_line_stream
      _ = st.gets
      _.should eql "wak and GAK\n"
      _ = st.gets
      _.should be_nil
    end
  end
end
