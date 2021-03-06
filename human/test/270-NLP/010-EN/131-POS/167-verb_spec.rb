require_relative '../../../test-support'

module Skylab::Human::TestSupport

  describe "[hu] NLP EN - verb" do

    it "verb phrase must be attached to noun phrase (e.g: prerite)" do

      np = _POS::Noun[ 'Jim' ]

      vp = _POS::Verb[ np, 'love' ]

      vp << :preterite

      expect( vp.to_string ).to eql 'loved'
    end

    it "verb phrase stays attached, using real-time state (e.g: present)" do

      np = _POS::Noun[ 'Jim' ]

      vp = _POS::Verb[ np, 'love' ]

      np << :third

      expect( vp.to_string ).to eql 'loves'
    end

    it "irregular (be, singular, first, present)" do

      np = _POS::Noun[ 'Jim' ]

      vp = _POS::Verb[ np, 'be' ]

      np << :third

      expect( vp.to_string ).to eql 'is'

    end

    it "progressive - new behavior in this edition" do

      np = _POS::Noun[ 'Jim' ]

      vp = _POS::Verb[ np, 'love' ]

      np << :third

      vp << :progressive

      expect( vp.to_string ).to eql 'is loving'
    end

    it "oneliner: preterite (\"do\")" do

      expect( _subject_module[ 'do' ].preterite ).to eql 'did'
    end

    it "oneliner: preterite (\"be\" - an edge case)" do

      # edge case [#040]:
      #
      # the verb lexeme "be" is the only one we can think of (regular
      # or irregular) that needs to know number and person while also
      # expressing preterite:
      #
      #   "{I | she } was"
      #   "{ you | we | they } were"
      #
      # as such it does not work well for the "single rule" nature of
      # this oneliner, which takes as practical input only lemma and the
      # rule name of "preterite".
      #
      # rather than making a unilateral decision for the client; we
      # leave the combinatorial expression, putting the onus on the
      # client to use a more adequate interface for its construction.

      expect( _subject_module[ 'be' ].preterite ).to eql 'was or were'
    end

    it "oneliner: progressive" do

      expect( _subject_module[ 'draw' ].progressive ).to eql 'drawing'
    end

    it "oneliner: singular third present" do

      expect( _subject_module[ 'miss' ].singular_third_present ).to eql 'misses'
    end

    it "(more granular interface)" do

      v_o = _subject_module[ 'have' ]

      v_o << :singular << :third << :present

      _ = v_o.express_into ""

      expect( _ ).to eql "has"
    end

    def _subject_module
      _POS::Verb
    end

    def _POS
      NLP_EN_.POS_lib
    end
  end
end
