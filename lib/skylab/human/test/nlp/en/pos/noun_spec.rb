require_relative '../../../test-support'

module Skylab::Human::TestSupport

  describe "[hu] NLP EN POS - noun" do

    extend TS_

    context "(jeefis)" do

      it "calling `[]` on the noun class gives you a noun *phrase*" do

        _np = _build_common_phrase
        _np.should be_respond_to :to_string
      end

      it "request components of the phrase" do

        _np = _build_common_phrase
        _np.adjective_phrase.should be_nil
      end

      it "out of the box you get a certain form" do

        _np = _build_common_phrase
        _np.to_string.should eql 'a jeefis'
      end

      it "look how you can mutate the lemma and the inflection happens" do

        np = _build_common_phrase
        np.to_string.should eql 'a jeefis'
        np.lemma_string = 'obelisk'
        np.to_string.should eql 'an obelisk'
      end

      it "inflect wit with `<<`" do

        np = _build_common_phrase
        np << :plural
        np.to_string.should eql 'jeefises'
      end

      it "you can go crazy and stack them, last one wins" do

        np = _build_common_phrase
        np << :singular << :indefinite << :plural << :definite
        np.to_string.should eql 'the jeefises'
      end

      def _build_common_phrase
        _subject_module[ 'jeefis' ]
      end
    end

    def _subject_module
      Home_::NLP::EN::POS::Noun
    end
  end
end
