require_relative '../../test-support'

module Skylab::Parse::TestSupport

  describe "[pa] functions - keyword - can fuzz (integration)" do

    TS_[ self ]

    memoize_subject_parse_function_ do

      Home_.function( :serial_optionals ).with(
        :functions,
        :keyword, 'zipili',
        :keyword, 'zipolo',
        :non_negative_integer,
        :keyword, 'zip' )

    end

    it "reach the front one with a hotstring" do
      k1, k2, d, k3 = _against 'zipi'
      expect( k1 ).to eql :zipili
      expect( k2 || d || k3 ).to be_nil
    end

    it "reach a non-front one with a hotstring" do
      k1, k2, d, k3 = _against 'zipo'
      expect( k2 ).to eql :zipolo
      expect( k1 || d || k3 ).to be_nil
    end

    it "get two adjacents in a row, using hostrings" do
      k1, k2, d, k3 = _against 'zipi', 'zipo'
      expect( k1 ).to eql :zipili
      expect( k2 ).to eql :zipolo
      expect( d || k3 ).to be_nil
    end

    it "reach an exact match keyword that is within the other keywords" do
      k1, k2, d, k3 = _against 'zip'
      expect( k3 ).to eql :zip
      expect( k1 || k2 || d ).to be_nil
    end

    it "(still you can reach non-keyword things)" do
      k1, k2, d, k3 = _against '1'
      expect( d ).to eql 1
      expect( k1 || k2 || k3 ).to be_nil
    end

    it "AMAZINGLY you can reach all of them still using hotstrings" do
      k1, k2, d, k3 = _against 'zipi', 'zipo', '2', 'zip'
      expect( [ k1, k2, d, k3 ] ).to eql [ :zipili, :zipolo, 2, :zip ]
    end

    it "and if you mess up the order you are S.O.L" do
      k1, k2, d, k3 = _against 'zip', '2'
      expect( k3 ).to eql :zip
      expect( k1 || k2 || d ).to be_nil
    end

    def _against * s_a
      against_input_array( s_a ).value
    end
  end
end
