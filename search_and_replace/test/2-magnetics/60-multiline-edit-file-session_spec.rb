require_relative '../test-support'

module Skylab::SearchAndReplace::TestSupport

  describe "[sa] magnetics - multiline edit file session" do

    TS_[ self ]
    use :memoizer_methods
    use :SES  # (only for 1 assertion method)

    shared_subject :_edit_session_array do

      _st = build_stream_for_single_path_to_file_with_three_lines_

      o = magnetics_::FileSession_Stream_via_Parameters.new( & no_events_ )
      o.upstream_path_stream = _st
      o.ruby_regexp = /e[\n!]/m
      o.for = :for_interactive_search_and_replace
      _es_st = o.execute

      _a = _es_st.to_a

      _a
    end

    it "this performer builds a stream of edit sessions, one per file" do

      _edit_session_array.length.should eql 1
    end

    it "the one edit session of that stream has 3 match controllers.." do

      _d = _match_controller_array.length
      _d.should eql 3
    end

    it "let's see if we can change the file (join 2 lines)" do

      _mc = _match_controller_array.fetch 1
      _mc.engage_replacement_via_string 'e - '

      _exp = unindent_ <<-HERE
        it's time for WAZOOZLE, see
          fazzoozle my noozle - when i say "wazoozle" i mean WaZOOzle!
      HERE

      expect_edit_session_output_ _exp
    end

    shared_subject :_match_controller_array do
      match_controller_array_for_ mutated_edit_session_
    end

    def mutated_edit_session_
      _edit_session_array.fetch 0
    end
  end
end
