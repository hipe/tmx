require_relative '../../../test-support'

module Skylab::Human::TestSupport

  describe "[hu] NLP EN POS - pronoun" do

    TS_[ self ]

    it "experimentally, entire np BECOMES pronoun by setting exponents" do

      np = _build_common_phrase
      np << :third
      np << :plural
      np << :neuter
      np << :subjective
      np.to_string.should eql 'they'
    end

    it "adding exponents reduces it to a possibly non-one number of forms" do

      # (this test is explored to an absurd depth in [#037]:#miranda-july)

      np = _build_common_phrase
      np << :third << :subjective

      np.to_string.should eql 'she, he or it'
    end

    it "a phrase that \"becomes\" a pronoun \"remembers\" its \"antecedent\"" do

      np = _build_common_phrase
      np << :third << :subjective << :plural

      np.to_string.should eql 'they'

      np.clear_grammatical_category :person
      np.clear_grammatical_category :case

      np.to_string.should eql 'jeefises'
    end

    def _build_common_phrase
      __gateway_module[ 'jeefis' ]
    end

    def __gateway_module
      NLP_EN_.POS_lib::Noun
    end
  end
end
