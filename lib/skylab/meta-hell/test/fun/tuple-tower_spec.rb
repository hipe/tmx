require_relative 'test-support'

module Skylab::MetaHell::TestSupport::Fun

  ::Skylab::MetaHell::TestSupport[ Fun_TestSupport = self ]

  include CONSTANTS

  MetaHell = ::Skylab::MetaHell  # increase its visibility for below modules

  extend TestSupport::Quickie

  Sandboxer = TestSupport::Sandbox::Spawner.new

  describe "Skylab::MetaHell::Fun" do
    context "context 1" do
      Sandbox_1 = Sandboxer.spawn
      it "opaque but comprehensive example:" do
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
          s = MetaHell::FUN.tuple_tower[ 'cilantro',  * f_a ]
          s.should eql( 'i hate cilantro' )
          s = MetaHell::FUN::tuple_tower[ 'carrots', * f_a ]
          s.should eql( "let's have carrots and potato" )
          s = MetaHell::FUN.tuple_tower[ 'red', * f_a ]
          s.should eql( 'nope i hate tomato' )
          x = MetaHell::FUN.tuple_tower[ 'blue', * f_a ]
          x.should eql( [ 'blue', 'potato' ] )
        end
      end
    end
  end
end
