require_relative 'test-support'

module Skylab::Basic::TestSupport

  describe "[ba] function (chain)" do

    context "given a queue of [..]" do

      _FUNC = nil

      before :all do

        _p_a = [
          -> item do
            if 'cilantro' == item            # the true-ishness of the 1st
              [ false, 'i hate cilantro' ]   # element in the result tuple
            else                             # determines short circuit
              [ true, item, ( 'red' == item ? 'tomato' : 'potato' ) ]
            end                              # three above becomes two
          end, -> item1, item2 do            # here, b.c the 1st is
            if 'carrots' == item1            # discarded when true
              "let's have carrots and #{ item2 }" # note no tuple necessary
            elsif 'tomato' == item2          # if it's just one true-ish
              [ false, 'nope i hate tomato' ]  # non-true item
            else
              [ item1, item2 ]
            end
          end ]

        _FUNC = Home_::Function.chain _p_a
      end

      it "this short circuits at [..[" do

        s = _FUNC[ 'cilantro' ]
        s.should eql 'i hate cilantro'
      end

      it "resulting in a [..]" do

        s = _FUNC[ 'carrots' ]
        s.should eql "let's have carrots and potato"
      end

      it "resulting in the tuple [..]" do

        s = _FUNC[ 'red' ]
        s.should eql 'nope i hate tomato'
      end

      it "this followed all the way through to the end with a true-ish itme" do

        x = _FUNC[ 'blue' ]
        x.should eql [ 'blue', 'potato' ]
      end
    end
  end
end
