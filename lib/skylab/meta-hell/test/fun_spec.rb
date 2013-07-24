require_relative 'test-support'

module Skylab::MetaHell::TestSupport::FUN

  ::Skylab::MetaHell::TestSupport[ FUN_TestSupport = self ]

  include CONSTANTS

  MetaHell = ::Skylab::MetaHell

  extend TestSupport::Quickie

  Sandboxer = TestSupport::Sandbox::Spawner.new

  describe "Skylab::MetaHell::FUN" do
    context "`seeded_function_chain` - given a stack of functions and one seed value," do
      Sandbox_1 = Sandboxer.spawn
      it "opaque but comprehensive example" do
        Sandbox_1.with self
        module Sandbox_1
          f_a = [
            -> item do
              if 'cilantro' == item                 # the true-ishness of the 1st
                [ false, 'i hate cilantro' ]        # element in the result tuple
              else                                  # determines short circuit
                [ true, item, ( 'red' == item ? 'tomato' : 'potato' ) ]
              end                                   # three above becomes two
            end, -> item1, item2 do                 # here, b.c the 1st is
              if 'carrots' == item1                 # discarded when true
                "let's have carrots and #{ item2 }" # note no tuple necessary
              elsif 'tomato' == item2               # if it's just one true-ish
                [ false, 'nope i hate tomato' ]     # non-true item
              else
                [ item1, item2 ]
              end
            end ]
          s = MetaHell::FUN.seeded_function_chain[ 'cilantro',  * f_a ]
          s.should eql( 'i hate cilantro' )
          s = MetaHell::FUN::seeded_function_chain[ 'carrots', * f_a ]
          s.should eql( "let's have carrots and potato" )
          s = MetaHell::FUN.seeded_function_chain[ 'red', * f_a ]
          s.should eql( 'nope i hate tomato' )
          x = MetaHell::FUN.seeded_function_chain[ 'blue', * f_a ]
          x.should eql( [ 'blue', 'potato' ] )
        end
      end
    end
  end
end
