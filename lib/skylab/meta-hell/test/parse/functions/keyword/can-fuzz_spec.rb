require_relative '../../test-support'

module Skylab::MetaHell::TestSupport::Parse

  describe "[mh] parse functions - keyword - can fuzz (integration)" do

    extend TS_

    define_method :subject, ( Callback_.memoize do

      Subject_[]::Functions_::Serial_Optionals.new_with(
        :functions,
        :keyword, 'zipili',
        :keyword, 'zipolo',
        :non_negative_integer,
        :keyword, 'zip' )

    end )

    it "reach the front one with a hotstring" do
      k1, k2, d, k3 = against 'zipi'
      k1.should eql :zipili
      ( k2 || d || k3 ).should be_nil
    end

    it "reach a non-front one with a hotstring" do
      k1, k2, d, k3 = against 'zipo'
      k2.should eql :zipolo
      ( k1 || d || k3 ).should be_nil
    end

    it "get two adjacents in a row, using hostrings" do
      k1, k2, d, k3 = against 'zipi', 'zipo'
      k1.should eql :zipili
      k2.should eql :zipolo
      ( d || k3 ).should be_nil
    end

    it "reach an exact match keyword that is within the other keywords" do
      k1, k2, d, k3 = against 'zip'
      k3.should eql :zip
      ( k1 || k2 || d ).should be_nil
    end

    it "(still you can reach non-keyword things)" do
      k1, k2, d, k3 = against '1'
      d.should eql 1
      ( k1 || k2 || k3 ).should be_nil
    end

    it "AMAZINGLY you can reach all of them still using hotstrings" do
      k1, k2, d, k3 = against 'zipi', 'zipo', '2', 'zip'
      [ k1, k2, d, k3 ].should eql [ :zipili, :zipolo, 2, :zip ]
    end

    it "and if you mess up the order you are S.O.L" do
      k1, k2, d, k3 = against 'zip', '2'
      k3.should eql :zip
      ( k1 || k2 || d ).should be_nil
    end

    def against * s_a
      against_input_array( s_a ).value_x
    end
  end
end
