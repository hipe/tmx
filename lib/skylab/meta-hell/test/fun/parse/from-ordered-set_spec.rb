require_relative 'test-support'

module Skylab::MetaHell::TestSupport::FUN::Parse::From_Ordered_Set

  ::Skylab::MetaHell::TestSupport::FUN::Parse[ From_Ordered_Set_TestSupport = self ]

  include CONSTANTS

  MetaHell = ::Skylab::MetaHell

  extend TestSupport::Quickie

  Sandboxer = TestSupport::Sandbox::Spawner.new

  describe "Skylab::MetaHell::FUN::Parse::From_Ordered_Set" do
    context "`parse_from_ordered_set` result is array of same length as `set_a`." do
      Sandbox_1 = Sandboxer.spawn
      before :all do
        Sandbox_1.with self
        module Sandbox_1
          PARSER = MetaHell::FUN.parse_from_ordered_set.curry[
            :argv_scanners, [
              -> args { args.shift if args.first =~ /bill/i },
              -> args { if :hi == args.first then args.shift and :hello end }]]
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
  end
end
