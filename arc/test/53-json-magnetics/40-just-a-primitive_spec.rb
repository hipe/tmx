require_relative '../test-support'

module Skylab::Arc::TestSupport

  describe "[arc] JSON magnetics - just a primitive" do

    TS_[ self ]
    use :memoizer_methods
    use :want_event
    use :want_root_ACS
    use :JSON_magnetics

    context "persist this ACS when empty - OK" do

      shared_subject :root_ACS_state do

        o = build_root_ACS
        _x = marshal_JSON_into [], o
        root_ACS_state_via _x, o
      end

      it "emits wrote" do
        expect( only_emission ).to be_emission( :info, :wrote )
      end

      it "output OK" do
        expect( root_ACS_result ).to eql _EMPTY_JSON_LINES
      end
    end

    context "persist this ACS when we hack a value into it" do

      shared_subject :root_ACS_state do

        o = build_root_ACS

        o.set_file_nerm :xx

        _x  = marshal_JSON_into "", :be_pretty, false, o
        root_ACS_state_via _x, o
      end

      it "emits wrote" do
        expect( only_emission ).to be_emission( :info, :wrote )
      end

      it "output" do
        expect( root_ACS_result ).to eql "{\"file_name\":\"xx\"}\n"
      end
    end

    context "when payload looks wrong:" do

      shared_subject :root_ACS_state do

        o = build_root_ACS

        _io = _fake_IO_via_json_lines '{"foo":"bar"}'

        _x = unmarshal_from_JSON o, _io
        root_ACS_state_via _x, o
      end

      it "fails" do
        expect( root_ACS_result ).to be_common_result_for_failure
      end

      it "emits" do
        expect( only_emission ).to be_emission( :error, :unrecognized_argument )
      end
    end

    context "when payload looks right - unmarshals OK" do

      shared_subject :root_ACS_state do

        o = build_root_ACS

        _io = _fake_IO_via_json_lines '{"file_name":"bar"}'

        _x = unmarshal_from_JSON o, _io
        root_ACS_state_via _x, o
      end

      it "emits nothing" do
        want_no_emissions
      end

      it "unmarshalled OK" do
        expect( root_ACS.read_file_nerm ).to eql 'bar'
      end
    end

    def _fake_IO_via_json_lines * s_a
      Home_::Stream_[ s_a ]
    end

    def subject_root_ACS_class
      Fixture_top_ACS_class[ :Class_04_Just_a_Primitive ]
    end
  end
end
