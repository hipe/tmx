require_relative 'test-support'

module Skylab::MetaHell::TestSupport::Fun

  ::Skylab::MetaHell::TestSupport[ Fun_TestSupport = self ]

  include CONSTANTS

  MetaHell = ::Skylab::MetaHell  # increase its visibility for below modules

  extend TestSupport::Quickie

  Sandboxer = TestSupport::Sandbox::Spawner.new

  describe "Skylab::MetaHell::Fun" do
    context "`parse_with_ordered_set` result is array of same length as `set_a`." do
      Sandbox_1 = Sandboxer.spawn
      before :all do
        Sandbox_1.with self
        module Sandbox_1
          PARSER = MetaHell::FUN.parse_with_ordered_set.curry[ [
            -> args { args.shift if args.first =~ /bill/i },
            -> args { if :hi == args.first then args.shift and :hello end } ] ]
        end
      end
      it "like so" do
        Sandbox_1.with self
        module Sandbox_1
          1.should eql( 1 )
        end
      end
      it "result array is in order of \"grammar\", not of elements in argv" do
        Sandbox_1.with self
        module Sandbox_1
          argv = [ :hi, 'BILLY', 'bob' ]
          one, two = PARSER.call argv
          one.should eql( 'BILLY' )
          two.should eql( :hello )
          argv.should eql( [ 'bob' ] )
        end
      end
      it "it cannot fail (if `set_a` is array of monadic functions and `argv` is ary)" do
        Sandbox_1.with self
        module Sandbox_1
          argv = [ :nope ]
          res = PARSER.call argv
          res.should eql( [ nil, nil ] )
          argv.should eql( [ :nope ] )
        end
      end
      it "an unparsable element will \"mask\" subsequent would-be parsables" do
        Sandbox_1.with self
        module Sandbox_1
          argv = [ :nope, 'BILLY', :hi ]
          res = PARSER.call argv
          res.should eql( [ nil, nil ] )
          argv.length.should eql( 3 )
        end
      end
    end
    context "`tuple_tower` - given a stack of functions and one seed value, resolve" do
      Sandbox_2 = Sandboxer.spawn
      it "opaque but comprehensive example" do
        Sandbox_2.with self
        module Sandbox_2
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
