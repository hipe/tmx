require_relative '../test-support'

module Skylab::Basic::TestSupport

  describe "[ba] function (chain)" do

    extend TS_
    use :memoizer_methods

    context "compose a \"function chain\" with a list of functions" do

      shared_subject :func do
        func = Home_::Function.chain( [
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

        func
      end

      it "result of the call is that second element of the tuple" do
        ( func[ 'cilantro' ] ).should eql "i hate cilantro"
      end

      it "the chain call" do
        ( func[ 'carrots' ] ).should eql "let's have carrots and potato"
      end

      it "result (`X`) has been found" do
        ( func[ 'red' ] ).should eql "nope i hate tomato"
      end

      it "going. for now, the result is just the tuple as-is" do
        ( func[ 'blue' ] ).should eql %w( blue potato )
      end
    end
  end
end
