require_relative 'test-support'

module Skylab::MetaHell::TestSupport::Lib

  describe "[mh] Lib__" do

    context "given a queue of functions and one seed value, produce one result" do

      before :all do
        FUNC = begin

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


          MetaHell_.function_chain.curry[ _p_a ]
        end
      end
      it "this short circuits at te first branch, resulting in a value" do
        s = FUNC[ 'cilantro' ]
        s.should eql 'i hate cilantro'
      end
      it "resulting in a single true-ish item will result in that value" do
        s = FUNC[ 'carrots' ]
        s.should eql "let's have carrots and potato"
      end
      it "resulting in the tuple [ false, X ] gives you X" do
        s = FUNC[ 'red' ]
        s.should eql 'nope i hate tomato'
      end
      it "this followed all the way through to the end with a true-ish itme" do
        x = FUNC[ 'blue' ]
        x.should eql [ 'blue', 'potato' ]
      end
    end
  end
end
