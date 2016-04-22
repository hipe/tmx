require_relative '../../test-support'

module Skylab::Autonomous_Component_System::TestSupport

  describe "[ac] modalities - JSON - of POS" do

    TS_[ self ]
    use :memoizer_methods
    use :expect_event
    use :expect_root_ACS
    use :modalities_JSON

    context "when the payload has an invalid primitivesque value COLD" do

      shared_subject :root_ACS_state do

        o = build_root_ACS

        _has_one_issue = <<-HERE.unindent
          {
            "subject": "i",
            "verb_phrase": {
              "verb": "love",
              "object": "CHOCOLATE"
            }
          }
        HERE

        _io = TestSupport_::Library_::StringIO.new _has_one_issue

        _x = unmarshal_from_JSON o, _io

        root_ACS_state_via _x, o
      end

      it "fails" do
        root_ACS_result.should be_common_result_for_failure
      end

      context "in an emission expression initiated by the component," do

        shared_subject :_em do

          _expag = expression_agent_for_expect_event
          em = only_emission
          em.reify_by do |p|
            _expag.calculate [], & p
          end
          em
        end

        it "the channel that the component chose stays as-is" do

          _em.channel_symbol_array.should eql [ :error, :expression, :nope ]
        end

        it "the predicate as expressed by the component is intact" do

          _s = _first_line
          _s.should be_include 'must be a lowercase word (had: "CHOCOLATE")'
        end

        it "any subsequent lines are expressed as-is" do

          __last_line.should eql "so i guess that's that.\n"
        end

        it "we re-place any parenthesis and punctuation correctly (and add newlines)" do

          s = _first_line
          s[ 0 ].should eql '('
          s[ -3 .. -1 ].should eql ".)\n"
        end

        it "we put the component name as the subject of the predicate" do

          _s = _first_line
          _s.should match %r(\A[^a-z]*object\b)
        end

        it "we add the trailing context as a chain of prepositional phrases" do

          _s = _first_line
          _s.should match %r( in "verb_phrase" in input JSON[^[:alpha:]]*\z)
        end

        def _first_line
          _em.cached_event_value.fetch 0
        end

        def __last_line
          _em.cached_event_value.fetch 1
        end
      end
    end

    context "persist this full ACS with values in it" do

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

      o.set_verb_phrase_for_expect_root_ACS o_

      o
    end

    def expression_agent_for_expect_event
      clean_expag_
    end

    def subject_root_ACS_class
      Fixture_top_ACS_class[ :Class_41_Sentence ]
    end
  end
end
