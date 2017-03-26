require_relative '../../../test-support'

module Skylab::Human::TestSupport

  describe "[hu] NLP EN mags - statementish" do

    # (OK to move some of these to future lower-level (lower-numbered) tests)

    TS_[ self ]
    use :memoizer_methods

    context "(context)" do

      it "subject phrase has lemma in its state (and builds)" do

        _ = _subject_phrase
        :hunter == _.lemma_symbol or fail
      end

      it "v.p has lemma in its state (and builds)" do

        _ = _verb_phrase.lemma_symbol
        :have == _ or fail
      end

      it "the statement expresses, exhibiting agreement (present tense)" do

        o = _begin_statement
        o.subject = _subject_phrase
        o.verb_phrase = _verb_phrase

        _s_of( o ).should eql "vampire hunter D has fun.\n"
      end

      it "preterite oh boy" do

        o = _begin_statement

        o.subject = _subject_phrase
        o.verb_phrase = _verb_phrase_as_preterite

        _s_of( o ).should eql "vampire hunter D had fun.\n"
      end

      it "but when no subject, passive voice OMG" do

        o = _begin_statement

        o.verb_phrase = _verb_phrase

        _s_of( o ).should eql "fun is had.\n"
      end

      it "passive voice in preterite" do

        o = _begin_statement

        o.verb_phrase = _verb_phrase_as_preterite

        _s_of( o ).should eql "fun was had.\n"
      end

      it "the ivariant be form" do

        o = _begin_statement

        _vp = _build( :predicateish,
          :lemma, :be,
          :object_noun_phrase, "crazy",
        )

        o.verb_phrase = _vp

        _ = _s_of( o )
        _.should eql "crazy\n"
      end

      shared_subject :_verb_phrase_as_preterite do

        _verb_phrase.dup << :preterite  # whoosh
      end

      shared_subject :_subject_phrase do

        _build( :nounish,
          :modifier_word_list, %w( vampire ),
          :lemma, :hunter,
          :proper_noun, 'D',
        )
      end

      shared_subject :_verb_phrase do

        _build( :predicateish,
          :lemma, :have,
          :object_noun_phrase, [ :nounish, :lemma, :fun ],
        )
      end
    end

    def _begin_statement
      NLP_EN_.lib::Magnetics::Statementish_via_Subject_and_VerbPhrase.begin_
    end

    def _build * sx
      NLP_EN_.sexp_lib.interpret_ Home_::Scanner_[ sx ]
    end

    def _s_of o
      o.express_into_under "", common_expag_
    end
  end
end
