require_relative 'test-support'

module Skylab::Basic::TestSupport

  describe "[ba] function (chain)" do

    context "given a queue of functions and one seed value, produce one result" do

      before :all do

        X_f_FUNC = Home_::Function.chain( [
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
          end,
        ] )
      end

      it "this short circuits at the first branch, resulting in a value" do
        s = X_f_FUNC[ 'cilantro' ]
        s.should eql 'i hate cilantro'
      end

      it "resulting in a single true-ish item will result in that value" do
        s = X_f_FUNC[ 'carrots' ]
        s.should eql "let's have carrots and potato"
      end

      it "resulting in the tuple [ false, X ] gives you X" do
        s = X_f_FUNC[ 'red' ]
        s.should eql 'nope i hate tomato'
      end

      it "this follows all the way through to the end with a true-ish item" do
        x = X_f_FUNC[ 'blue' ]
        x.should eql [ 'blue', 'potato' ]
      end
    end
  end
end
