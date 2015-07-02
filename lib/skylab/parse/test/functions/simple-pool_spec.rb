require_relative '../test-support'

module Skylab::Parse::TestSupport

  module Fz_SP___  # :+#throwaway-module for constants generated during tests
    # <-
  TS_.describe "[pa] functions - simple pool" do

    context "with an ordered set parser (built from a list of arbitrary procs)" do

      before :all do
        bill_rx = /bill/i

        SP = Home_.function( :simple_pool ).new_with(
          :functions,
            :trueish_mapper, -> in_st do
              if bill_rx =~ in_st.current_token_object.value_x
                in_st.gets_one.value_x
              end
            end,
            :trueish_mapper, -> in_st do
              if :hi == in_st.current_token_object.value_x
                in_st.advance_one
                :hello
              end
            end )
      end

      it "result array is in order of \"grammar\", not of elements in argv" do
        argv = [ :hi, 'BILLY', 'bob' ]
        one, two = SP.parse_and_mutate_array argv
        one.should eql 'BILLY'
        two.should eql :hello
        argv.should eql [ 'bob' ]
      end

      it "cannot fail (if arguments have the right shape)" do
        argv = [ :nope ]
        res = SP.parse_and_mutate_array argv
        res.should eql [ nil, nil ]
        argv.should eql [ :nope ]
      end

      it "an unparsable element will \"mask\" subsequent would-be parsables" do
        argv = [ :nope, 'BILLY', :hi ]
        res = SP.parse_and_mutate_array argv
        res.should eql [ nil, nil ]
        argv.length.should eql 3
      end
    end
  end
  # ->
  end
end
