require_relative '../../test-support'

module Skylab::Autonomous_Component_System::TestSupport

  describe "[ac] modalities - JSON - of POS" do

    TS_[ self ]
    use :memoizer_methods
    use :expect_event
    use :expect_root_ACS
    use :modalities_JSON

    context "when payload looks wrong:" do

      shared_subject :root_ACS_state do

        o = build_root_ACS

        _wrong = <<-HERE.unindent
          {
            "subject": "i",
            "verb_phrase": {
              "verb": "love",
              "object": "/chocolate"
            }
          }
        HERE

        _io = TestSupport_::Library_::StringIO.new _wrong

        _x = unmarshal_from_JSON o, _io

        root_ACS_state_via _x, o
      end

      it "fails" do
        root_ACS_result.should be_common_result_for_failure
      end

      it "emits (no contextualization yet)" do

        only_emission.should ( be_emission(
          :error, :expression, :invalid_value
        ) do | y |

          y.should eql [ "paths can't be absolute - '/chocolate'" ]

        end )
      end
    end

    context "persist this full ACS when we hack values into it" do

      shared_subject :root_ACS_state do

        o = __build_full_graph

        _x = marshal_JSON_into "", o

        root_ACS_state_via _x, o
      end

      it "emits" do
        only_emission.should be_emission( :info, :wrote )
      end

      it "output" do

        _exp = <<-HERE.unindent
          {
            "subject": "i",
            "verb_phrase": {
              "verb": "love",
              "object": "chocolate"
            }
          }
        HERE

        root_ACS_result.should eql _exp
      end
    end

    def __build_full_graph

      o = build_root_ACS

      o._set_subject 'i'

      o_ = const_( :Verb_Phrase ).new( & No_events_pp_ )

      o_._set_verb 'love'

      o_._set_object 'chocolate'

      o._set_verb_phrase o_

      o
    end

    def subject_root_ACS_class
      Fixture_top_ACS_class[ :Class_41_Sentence ]
    end

    def expression_agent_for_expect_event
      Home_.lib_.brazen::API.expression_agent_instance
    end
  end
end
