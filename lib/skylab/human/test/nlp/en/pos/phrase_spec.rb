require_relative '../../../test-support'

module Skylab::Human::TestSupport

  module NLP_EN_POS_P___  # :+#throwaway-module

    # <-

  TS_.describe "[hu] NLP EN POS - phrase" do

    context "lexemes and productions" do

      context "a regular verb conjugates" do

        it "as lemma - the string from `to_string` is persistent and immutable" do

          v = _parent_subject::Verb._new_production_via 'look'
          v.to_string.should eql "look"

          _oid = v.to_string.object_id
          v.to_string.object_id.should eql _oid

          s = v.to_string
          begin
            s.concat ''
          rescue ::RuntimeError => e
          end
          e.message.should match %r(\bcan't modify frozen String\b)
        end

        it "(lexicon caches every new lexeme for now)" do

          p1 = _parent_subject::Verb._new_production_via 'bizzle'
          s1 = p1.to_string

          p2 = _parent_subject::Verb._new_production_via 'bizzle'
          s2 = p2.to_string

          ( p1.object_id == p2.object_id ).should eql false
          ( s1.object_id == s2.object_id ).should eql true  # same lexeme
        end

        it "preterite" do

          prd = _build_production

          prd.__mutate_against_exponent :preterite

          prd.to_string.should eql "looked"
        end

        it "third singular" do

          prd = _build_production

          prd.__mutate_against_exponent :third_singular

          prd.to_string.should eql "looks"
        end

        it "strange - borks early" do

          prd = _build_production

          begin
            prd.__mutate_against_exponent :_strange_
          rescue ::KeyError => e
          end

          e.message.should match %r(\bno exponent "_strange_")
        end

        def _build_production

          _parent_subject::Verb._new_production_via 'look'
        end
      end

      context "an irregular verb conjugates (from a lexicon)" do

        it "lemma" do

          _parent_subject::Verb._new_production_via( 'have' ).to_string.should eql 'have'
        end

        it "you can look it up with a conjugated form - works as expected" do

          neato = _parent_subject::Verb._new_production_via 'has'
          meato = _parent_subject::Verb._new_production_via 'have'

          neato.to_string.should eql 'has'
          meato.to_string.should eql 'have'

          both = [ neato, meato ]
          both.map( & :object_id ).uniq.length.should eql 2

          both.map do |prod|

            x = prod.instance_variable_get( :@_lemma_ID_x ) or fail
            x.object_id

          end.uniq.length.should eql 1
        end

        it "preterite, third singular" do

          o = _build_production
          o.to_string.should eql "have"

          o.__mutate_against_exponent :preterite
          o.to_string.should eql "had"

          o.__mutate_against_exponent :third_singular
          o.to_string.should eql "has"
        end

        def _build_production
          _parent_subject::Verb._new_production_via 'have'
        end
      end
    end

    context "combinatorily inflective lexemes (The Pronoun)" do

      it "a pronoun remembers its surface form" do

        _parent_subject::Noun._new_production_via( 'I' ).to_string.should eql 'I'
      end

      it "set a grammatical category to a bad exponent - key error" do

        pron = _her
        begin
          pron.gender = :multisex
        rescue ::KeyError => e
        end

        e.message.should match %r(\bbad exponent for gender - multis)
      end

      it "set a grammatical category to a good exponent - zing" do

        prd = _her
        prd.to_string.should eql 'her'
        prd.gender.should eql :feminine

        prd.gender = :masculine
        prd.gender.should eql :masculine

        prd.to_string.should eql 'him'
      end

      def _her

        _parent_subject::Noun._new_production_via 'her'
      end

      it "FUZZY GRAMMATICAL CATEGORY STATE (unknown) - ALTERNATION" do

        prd = _parent_subject::Noun._new_production_via 'he'

        prd.to_string.should eql 'he'

        prd.gender = nil

        prd.to_string.should eql "she or he or it"
      end
    end

    context "phrases and productions" do

      context "cogito ergo sum" do

        combi = -> prod do

          prod.instance_variable_get :@_combination
        end

        lem_x = -> prod do

          prod.instance_variable_get :@_lemma_ID_x
        end

        # #todo - loosen this test or eliminate it later. it's a joist

        it "builds a tagged POS tree from tagged input" do

          sp = _subject._new_production_via np: 'I', vp: 'think'

          sp.np.n._lexeme_class.should eql sp.np.n.class._lexeme_class

          sp.np.n._lexeme_class::Production || nil  # should not raise

          c = combi[ sp.np.n ]

          c.members.should eql [ :markedness, :case, :gender, :number, :person]

          c.values.should eql [ nil, :subjective, nil, :singular, :first ]

          lem_x[ sp.vp.v ].should eql 'think'

          c = combi[ sp.vp.v ]

          c.values.compact.should eql [ :lemma ]

          sp.vp.v._lexeme_class::Production || nil  # should not raise
        end

        it "renders" do

          _build_sp.to_string.should eql "I think"
        end

        it "lets you change the exponents of a constituent" do

          sp = _build_sp
          sp.np.n.person = :second
          sp.to_string.should eql "you think"
        end

        it "an exponent can hackisly trickle down to the first relevant node" do

          sp = _build_sp

          sp.tense = :preterite
          sp.to_string.should eql "I thinked"  # haha

          sp.person = :third
          sp.to_string.should eql "she or he or it thinked"  # FSCKING AWSM

          sp.gender = :masculine
          sp.to_string.should eql "he thinked"
        end

        def _build_sp

          _subject._new_production_via np: 'I', vp: 'think'
        end
      end
    end

    context "subject verb agreement" do

      it "verb agrees with subject (sorta hacked)" do

        sp = _build_sp

        sp.gender = :feminine
        sp.to_string.should eql "I balk"

        sp.person = :third
        sp.to_string.should eql "she balks or balk"

        sp.number = :singular
        sp.to_string.should eql "she balks"
      end

      def _build_sp
        _subject._new_production_via np: 'I', vp: 'balk'
      end
    end

    context "original target use case" do

      it "assumes no number!, trickles down e.g tense" do

        sp = _build_sp

        sp.to_string.should eql(
          "julie or julies has aspiration or aspirations" )

        sp.np.number = sp.vp.np.number = :singular
        sp.to_string.should eql "julie has aspiration"

        sp.tense = :preterite
        sp.vp.np.number = :plural
        sp.to_string.should eql "julie had aspirations"
      end

      def _build_sp
        _subject._new_production_via(
          np: 'julie',
          vp: { v: 'has', np: 'aspiration' } )
      end
    end

    def _parent_subject
      Hu_::NLP::EN::POS
    end

    def _subject
      _parent_subject::Sentence::Phrase
    end
  end
# ->
  end
end
