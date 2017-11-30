require_relative '../test-support'

module Skylab::Arc::TestSupport

  describe "[arc] JSON magnetics - sentence" do

    TS_[ self ]
    use :memoizer_methods
    use :want_event
    use :want_root_ACS
    use :JSON_magnetics

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
        expect( root_ACS_result ).to be_common_result_for_failure
      end

      context "in an emission expression initiated by the component," do

        shared_subject :_em_tuple do

          em = only_emission
          em.is_expression || fail

          _expag = expression_agent_for_want_emission
          _lines = _expag.calculate [], & em.expression_proc

          [ _lines, em ]
        end

        it "the channel that the component chose stays as-is" do

          expect( _em_tuple.last.channel_symbol_array ).to eql [ :error, :expression, :nope ]
        end

        it "the predicate as expressed by the component is intact" do

          _s = _first_line
          expect( _s ).to be_include 'must be a lowercase word (had: "CHOCOLATE")'
        end

        it "any subsequent lines are expressed as-is" do

          expect( __last_line ).to eql "so i guess that's that.\n"
        end

        it "we re-place any parenthesis and punctuation correctly (and add newlines)" do

          s = _first_line
          expect( s[ 0 ] ).to eql '('
          expect( s[ -3 .. -1 ] ).to eql ".)\n"
        end

        it "we put the component name as the subject of the predicate" do

          _s = _first_line
          expect( _s ).to match %r(\A[^a-z]*object\b)
        end

        it "we add the trailing context as a chain of prepositional phrases" do

          _s = _first_line
          expect( _s ).to match %r( in "verb_phrase" in input JSON[^[:alpha:]]*\z)
        end

        def _first_line
          _em_tuple.first.fetch 0
        end

        def __last_line
          _em_tuple.first.fetch 1
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
        expect( only_emission ).to be_emission( :info, :wrote )
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

        _act = root_ACS_result

        expect( _act ).to eql _exp
      end
    end

    def __build_full_graph

      o = build_root_ACS

      o._set_subject 'i'

      o_ = const_( :Verb_Phrase ).new( & No_events_pp_ )

      o_._set_verb 'love'

      o_._set_object 'chocolate'

      o.set_verb_phrase_for_want_root_ACS o_

      o
    end

    def expression_agent_for_want_emission
      expag_for_cleanliness_
    end

    def subject_root_ACS_class
      Fixture_top_ACS_class[ :Class_41_Sentence ]
    end
  end
end
