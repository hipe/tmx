require_relative '../test-support'

module Skylab::Parse::TestSupport

  describe "[pa] functions - integer" do

    TS_[ self ]

    it "non-integer - no" do
      _against( 'foo' ).should be_nil
    end

    it "against float - no" do
      _against( '1.2' ).should be_nil
    end

    it "against int - yes" do
      _against( '123' ).should eql 123
    end

    it "against neg int - no" do
      _against( '-1' ).should be_nil
    end

    def _against s

      on = subject_parse_function_.output_node_via_input_stream(
        Home_::Input_Streams_::Single_Token.new s )

      if on
        on.value_x
      end
    end

    memoize_subject_parse_function_ do

      Home_.function( :non_negative_integer ).via_argument_scanner_passively(
        Common_::THE_EMPTY_SCANNER
      )
    end
  end
end
