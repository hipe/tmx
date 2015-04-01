require_relative '../test-support'

module Skylab::MetaHell::TestSupport::Parse

  describe "[mh] parse functions - integer" do

    extend TS_

    it "non-integer - no" do
      against( 'foo' ).should be_nil
    end

    it "against float - no" do
      against( '1.2' ).should be_nil
    end

    it "against int - yes" do
      against( '123' ).should eql 123
    end

    it "against neg int - no" do
      against( '-1' ).should be_nil
    end

    def against s
      on = subject.output_node_via_input_stream(
        Subject_[]::Input_Streams_::Single_Token.new s )
      if on
        on.value_x
      end
    end

    memoize_subject do
      Subject_[].function_( :non_negative_integer ).
        new_via_iambic_stream_passively(
          Callback_::Polymorphic_Stream.the_empty_iambic_stream )
    end
  end
end
