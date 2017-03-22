require_relative '../../../test-support'

module Skylab::Human::TestSupport

  describe "[hu] NLP EN - verb" do

    it "verb phrase must be attached to noun phrase (e.g: prerite)" do

      np = _POS::Noun[ 'Jim' ]

      vp = _POS::Verb[ np, 'love' ]

      vp << :preterite

      vp.to_string.should eql 'loved'
    end

    it "verb phrase stays attached, using real-time state (e.g: present)" do

      np = _POS::Noun[ 'Jim' ]

      vp = _POS::Verb[ np, 'love' ]

      np << :third

      vp.to_string.should eql 'loves'
    end

    it "irregular (be, singular, first, present)" do

      np = _POS::Noun[ 'Jim' ]

      vp = _POS::Verb[ np, 'be' ]

      np << :third

      vp.to_string.should eql 'is'

    end

    it "progressive - new behavior in this edition" do

      np = _POS::Noun[ 'Jim' ]

      vp = _POS::Verb[ np, 'love' ]

      np << :third

      vp << :progressive

      vp.to_string.should eql 'is loving'
    end

    it "oneliner: preterite (\"do\")" do

      _subject_module[ 'do' ].preterite.should eql 'did'
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

      _subject_module[ 'be' ].preterite.should eql 'was or were'
    end

    it "oneliner: progressive" do

      _subject_module[ 'draw' ].progressive.should eql 'drawing'
    end

    it "oneliner: singular third present" do

      _subject_module[ 'miss' ].singular_third_present.should eql 'misses'
    end

    it "(more granular interface)" do

      v_o = _subject_module[ 'have' ]

      v_o << :singular << :third << :present

      _ = v_o.express_into ""

      _.should eql "has"
    end

    def _subject_module
      _POS::Verb
    end

    def _POS

      Home_::NLP::EN::POS
    end
  end
end
