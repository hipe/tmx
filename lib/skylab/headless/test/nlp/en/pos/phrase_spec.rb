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

        it "as lemma - string is persistent and immutable", ok:true do
          v = NLP::EN::POS::Verb.produce 'look'
          v.string.should eql( 'look' )
          oid = v.string.object_id
          v.string.object_id.should eql( oid )
          -> do
            v.string.concat ''
          end.should raise_error( ::RuntimeError, /can't modify frozen string/ )
        end

        let :production do
          NLP::EN::POS::Verb.produce 'look'
        end

        it "preterite", ok:true do
          production.exponent = :preterite
          production.string.should eql( 'looked' )
        end

        it "third singular", ok:true do
          production.exponent = :third_singular
          production.string.should eql( 'looks' )
        end

        it "strange - borks early", ok:true do
          -> do
            production.exponent = :strange
          end.should raise_error( ::KeyError, /no exponent "strange"/ )
        end
      end

      context "an irregular verb conjugates (from a lexicon)" do

        it "lemma", ok:true do
          x = NLP::EN::POS::Verb.produce 'have'
          x.string.should eql( 'have' )
        end

        it "you can look it up with a conjugated form - works as expected", ok:true do
          neato = NLP::EN::POS::Verb.produce 'has'
          meato = NLP::EN::POS::Verb.produce 'have'
          neato.string.should eql( 'has' )
          meato.string.should eql( 'have' )
          both = [ neato, meato ]
          both.map( &:object_id ).uniq.length.should eql( 2 )
          both.map { |prod| prod.lemma_ref.object_id }.uniq.
            length.should eql( 1 )
        end

        let :production do
          NLP::EN::POS::Verb.produce 'have'
        end

        it "preterite, third singular", ok:true do
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

      it "set a grammatical category to a bad exponent - key error", ok:true do
        p = her
        -> do
          p.gender = :multisex
        end.should raise_error( ::KeyError, /bad exponent for gender - multis/ )
      end

      it "set a grammatical category to a good exponent - zing", ok:true do
        p = her
        p.string.should eql( 'her' )
        p.gender.should eql( :feminine )
        p.gender = :masculine
        p.gender.should eql( :masculine )
        p.string.should eql( 'him' )
      end

      it "FUZZY GRAMMATICAL CATEGORY STATE (unknown) - ALTERNATION", ok:true do
        p = NLP::EN::POS::Noun.produce 'he'
        p.string.should eql( 'he' )
        p.gender = nil
        x = p.string
        x.should eql( 'she or he or it' )
      end
    end

    context "phrases and productions" do

      context "cogito ergo sum" do

        # #todo - loosen this test or eliminate it later. it's a joist
        it "builds a tagged POS tree from tagged input", ok:true do
          sp = NLP::EN::POS::Sentence::Phrase.new np: 'I', vp: 'think'
          sp.np.n.lexeme_class.should eql( sp.np.n.class.lexeme_class )
          sp.np.n.lexeme_class::Production || nil  # should not raise
          sp.np.n.exponent_ref.members.should eql(
            [ :person, :number, :case, :gender ]
          )
          sp.np.n.exponent_ref.values.should eql(
            [ :first, :singular, :subjective, nil ]
          )
          sp.vp.v.lemma_ref.should eql( 'think' )
          sp.vp.v.exponent_ref.should eql( :lemma )
          sp.vp.v.lexeme_class::Production || nil  # should not raise
        end

        let :sp do
          NLP::EN::POS::Sentence::Phrase.new np: 'I', vp: 'think'
        end

        it "renders", ok:true do
          sp.string.should eql( 'I think' )
        end

        it "lets you change the exponents of a constituent", ok:true do
          sp.np.n.person = :second
          sp.string.should eql( 'you think' )
        end

        it "an exponent can hackisly trickle down to the first relevant node", f:true do
          sp = self.sp
          sp.tense = :preterite
          sp.string.should eql( 'I thinked' )  # haha
        end
      end

#      let :sp do
#        NLP::EN::POS::Phrase::Sentence.new np: 'julie',
#          vp: { v: 'has', np: 'aspiration' }
#      end

#      it "bangs out the simple case" do
#        res = sp.render
#        res.should eql( 'julie has aspiration' )
#      end

#      it "modifies the first constituent node that accepts the request" do
#        sp = self.sp
#        sp.modify :preterite
#        require 'debugger' ; debugger ; 1==1||nil

#      end
    end
  end
end
