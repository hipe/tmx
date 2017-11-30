require_relative '../test-support'

module Skylab::Parse::TestSupport

  describe "[pa] functions - integer" do

    TS_[ self ]

    it "non-integer - no" do
      expect( _against 'foo' ).to be_nil
    end

    it "against float - no" do
      expect( _against '1.2' ).to be_nil
    end

    it "against int - yes" do
      expect( _against '123' ).to eql 123
    end

    it "against neg int - no" do
      expect( _against '-1' ).to be_nil
    end

    def _against s

      on = subject_parse_function_.output_node_via_input_stream(
        Home_::Input_Streams_::Single_Token.new s )

      if on
        on.value
      end
    end

    memoize_subject_parse_function_ do

      Home_.function( :non_negative_integer ).via_argument_scanner_passively(
        Common_::THE_EMPTY_SCANNER
      )
    end
  end
end
