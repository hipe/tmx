require_relative '../../test-support'

module Skylab::Snag::TestSupport

  describe "[sg] models - criteria - integration" do

    extend TS_
    use :expect_event

      it "LTE and GT in a boolean expression" do

        call_API :criteria, :to_stream, :criteria,

          %w( nodes that have an identifier with an integer
              less than or equal to 3
              and greater than 1 ),

          :upstream_identifier, Path_alpha_[]

        st = @result

        st.gets.ID.to_i.should eql 3
        st.gets.ID.to_i.should eql 2
        st.gets.should be_nil
      end
  end
end
