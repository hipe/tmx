require_relative '../test-support'

module Skylab::Parse::TestSupport

  describe "[pa] functions - simple pool" do

    context "with an ordered set parser (built from a list of arbitrary procs)" do

      before :all do
        X_f_sp_SP = Home_.function( :simple_pool ).with(
          :functions,
            :trueish_mapper, -> in_st do
              if /bill/i =~ in_st.current_token_object.value
                in_st.gets_one.value
              end
            end,
            :trueish_mapper, -> in_st do
              if :hi == in_st.current_token_object.value
                in_st.advance_one
                :hello
              end
            end,
        )
      end

      it "result array is in order of \"grammar\", not of elements in argv" do
        argv = [ :hi, 'BILLY', 'bob' ]
        one, two = X_f_sp_SP.parse_and_mutate_array argv
        expect( one ).to eql 'BILLY'
        expect( two ).to eql :hello
        expect( argv ).to eql [ 'bob' ]
      end

      it "cannot fail (if arguments have the right shape)" do
        argv = [ :nope ]
        res = X_f_sp_SP.parse_and_mutate_array argv
        expect( res ).to eql [ nil, nil ]
        expect( argv ).to eql [ :nope ]
      end

      it "an unparsable element will \"mask\" subsequent would-be parsables" do
        argv = [ :nope, 'BILLY', :hi ]
        res = X_f_sp_SP.parse_and_mutate_array argv
        expect( res ).to eql [ nil, nil ]
        expect( argv.length ).to eql 3
      end
    end
  end
end
