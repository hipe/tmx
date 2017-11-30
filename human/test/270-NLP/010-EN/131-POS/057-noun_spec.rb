require_relative '../../../test-support'

module Skylab::Human::TestSupport

  describe "[hu] NLP EN POS - noun" do

    TS_[ self ]

    context "(jeefis)" do

      it "calling `[]` on the noun class gives you a noun *phrase*" do

        _np = _build_common_phrase
        expect( _np ).to be_respond_to :to_string
      end

      it "request components of the phrase" do

        _np = _build_common_phrase
        expect( _np.adjective_phrase ).to be_nil
      end

      it "out of the box you get a certain form" do

        _np = _build_common_phrase
        expect( _np.to_string ).to eql 'a jeefis'
      end

      it "look how you can mutate the lemma and the inflection happens" do

        np = _build_common_phrase
        expect( np.to_string ).to eql 'a jeefis'
        np.lemma_string = 'obelisk'
        expect( np.to_string ).to eql 'an obelisk'
      end

      it "inflect wit with `<<`" do

        np = _build_common_phrase
        np << :plural
        expect( np.to_string ).to eql 'jeefises'
      end

      it "you can go crazy and stack them, last one wins" do

        np = _build_common_phrase
        np << :singular << :indefinite << :plural << :definite
        expect( np.to_string ).to eql 'the jeefises'
      end

      def _build_common_phrase
        _subject_module[ 'jeefis' ]
      end
    end

    def _subject_module
      NLP_EN_.POS_lib::Noun
    end
  end
end
