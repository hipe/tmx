require_relative '../test-support'

module Skylab::Arc::TestSupport

  describe "[arc] modalities - JSON - empty" do

    TS_[ self ]
    use :memoizer_methods
    use :expect_event
    use :expect_root_ACS
    use :JSON_magnetics

    context "persist the empty ACS" do

      shared_subject :root_ACS_state do

        o = build_root_ACS
        _x = marshal_JSON_into [], o
        root_ACS_state_via _x, o
      end

      it "looks as it does (an empty JSON object)" do

        root_ACS_state.result.should eql _EMPTY_JSON_LINES
      end

      it "emits an event talking bout path and bytes" do

        only_emission.should ( be_emission :info, :wrote do | ev |

          ev.path and fail
          ev.bytes or fail

          black_and_white( ev ).should eql "wrote 3 bytes"
        end )
      end
    end

    context "unmarshals when payload looks right (no trailing newline necessary)" do

      shared_subject :root_ACS_state do

        o = build_root_ACS

        _io = Common_::Stream.via_nonsparse_array ['{}']

        _x = unmarshal_from_JSON o, _io

        root_ACS_state_via _x, o
      end

      it "cannot be done - fails" do
        root_ACS_result.should be_common_result_for_failure
      end

      it "error explains this" do

        only_emission.should ( be_emission :error, :empty_object do | ev |

          _s = black_and_white ev
          _s.should eql 'for now, will not parse empty JSON object for input JSON'
        end )
      end
    end

    def subject_root_ACS_class
      Fixture_top_ACS_class[ :Class_01_Empty ]
    end
  end
end
