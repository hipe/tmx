require_relative '../test-support'

module Skylab::Headless::TestSupport::NLP::EN::Phrase

  ::Skylab::Headless::TestSupport::NLP::EN[ self ]

  # le Quickie.

  include ::Skylab::Headless  # so you can say 'NLP' (before below!)
  include CONSTANTS  # so you can sat 'TS' (the right one!) (after above!)

  extend TestSupport::Quickie

  describe "#{ NLP::EN::POS } - Phrase" do

    context "lexemes and productions" do

      context "a regular verb cojugates" do

        it "as lemma - string is persistent and immutable" do
          v = NLP::EN::POS::Verb.produce 'look'
          v.string.should eql( 'look' )
          oid = v.string.object_id
          v.string.object_id.should eql( oid )
          -> do
            v.string.concat ''
          end.should raise_error( ::RuntimeError, /can't modify frozen String/ )
        end

        it "(lexicon caches every new lexeme for now)" do
          p1 = NLP::EN::POS::Verb.produce 'bizzle'
          s1 = p1.string
          p2 = NLP::EN::POS::Verb.produce 'bizzle'
          s2 = p2.string
          ( p1.object_id == p2.object_id ).should eql( false )
          ( s1.object_id == s2.object_id ).should eql( true )  # same lexeme
        end

        let :production do
          NLP::EN::POS::Verb.produce 'look'
        end

        it "preterite" do
          production.exponent = :preterite
          production.string.should eql( 'looked' )
        end

        it "third singular" do
          production.exponent = :third_singular
          production.string.should eql( 'looks' )
        end

        it "strange - borks early" do
          -> do
            production.exponent = :strange
          end.should raise_error( ::KeyError, /no exponent "strange"/ )
        end
      end

      context "an irregular verb conjugates (from a lexicon)" do

        it "lemma" do
          x = NLP::EN::POS::Verb.produce 'have'
          x.string.should eql( 'have' )
        end

        it "you can look it up with a conjugated form - works as expected" do
          neato = NLP::EN::POS::Verb.produce 'has'
          meato = NLP::EN::POS::Verb.produce 'have'
          neato.string.should eql( 'has' )
          meato.string.should eql( 'have' )
          both = [ neato, meato ]
          both.map( &:object_id ).uniq.length.should eql( 2 )
          both.map do |prod|
            x = prod.instance_variable_get( :@lemma_ref ) or fail "helff"
            x.object_id
          end.uniq.length.should eql( 1 )
        end

        let :production do
          NLP::EN::POS::Verb.produce 'have'
        end

        it "preterite, third singular" do
          production.string.should eql( 'have' )
          production.exponent = :preterite
          production.string.should eql( 'had' )
          production.exponent = :third_singular
          production.string.should eql( 'has' )
        end
      end
    end

    context "combinatorily inflective lexemes (The Pronoun)" do

      it "a pronoun remembers its surface form" do
        p = NLP::EN::POS::Noun.produce 'I'
        p.string.should eql( 'I' )
      end

      let :her do
        NLP::EN::POS::Noun.produce 'her'
      end

      it "set a grammatical category to a bad exponent - key error" do
        p = her
        -> do
          p.gender = :multisex
        end.should raise_error( ::KeyError, /bad exponent for gender - multis/ )
      end

      it "set a grammatical category to a good exponent - zing" do
        p = her
        p.string.should eql( 'her' )
        p.gender.should eql( :feminine )
        p.gender = :masculine
        p.gender.should eql( :masculine )
        p.string.should eql( 'him' )
      end

      it "FUZZY GRAMMATICAL CATEGORY STATE (unknown) - ALTERNATION" do
        p = NLP::EN::POS::Noun.produce 'he'
        p.string.should eql( 'he' )
        p.gender = nil
        x = p.string
        x.should eql( 'she or he or it' )
      end
    end

    context "phrases and productions" do

      context "cogito ergo sum" do

        combi = -> prod do
          prod.instance_variable_get :@combination
        end

        lem_x = -> prod do
          prod.instance_variable_get :@lemma_ref
        end

        # #todo - loosen this test or eliminate it later. it's a joist
        it "builds a tagged POS tree from tagged input" do
          sp = NLP::EN::POS::Sentence::Phrase.new np: 'I', vp: 'think'
          sp.np.n.lexeme_class.should eql( sp.np.n.class.lexeme_class )
          sp.np.n.lexeme_class::Production || nil  # should not raise
          c = combi[ sp.np.n ]
          c.members.should eql([ :markedness, :case, :gender, :number, :person])
          c.values.should eql( [ nil, :subjective, nil, :singular, :first ])
          lem_x[ sp.vp.v ].should eql( 'think' )
          c = combi[ sp.vp.v ]
          c.values.compact.should eql( [:lemma] )
          sp.vp.v.lexeme_class::Production || nil  # should not raise
        end

        let :sp do
          NLP::EN::POS::Sentence::Phrase.new np: 'I', vp: 'think'
        end

        it "renders" do
          sp.string.should eql( 'I think' )
        end

        it "lets you change the exponents of a constituent" do
          sp.np.n.person = :second
          sp.string.should eql( 'you think' )
        end

        it "an exponent can hackisly trickle down to the first relevant node" do
          sp = self.sp
          sp.tense = :preterite
          sp.string.should eql( 'I thinked' )  # haha
          sp.person = :third
          sp.string.should eql( 'she or he or it thinked' ) # FSCKING AWSM
          sp.gender = :masculine
          sp.string.should eql( 'he thinked' )
        end
      end
    end

    context "subject verb agreement" do
      let :sp do
        NLP::EN::POS::Sentence::Phrase.new np: 'I', vp: 'balk'
      end

      it "verb agrees with subject (sorta hacked)" do
        sp = self.sp
        sp.gender = :feminine
        sp.string.should eql( 'I balk' )
        sp.person = :third
        sp.string.should eql( 'she balks' )
      end
    end

    context "original target use case" do
      let :sp do
        NLP::EN::POS::Sentence::Phrase.new np: 'julie',
          vp: { v: 'has', np: 'aspiration' }
      end

      it "assumes no number!, trickles down e.g tense" do
        sp.string.should eql(
          'julie or julies has aspiration or aspirations' )
        sp.np.number = sp.vp.np.number = :singular
        sp.string.should eql( 'julie has aspiration' )
        sp.tense = :preterite
        sp.vp.np.number = :plural
        sp.string.should eql( 'julie had aspirations' )
      end
    end
  end
end
