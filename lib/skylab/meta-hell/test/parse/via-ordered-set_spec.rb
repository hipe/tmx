require_relative 'test-support'

module Skylab::MetaHell::TestSupport::Parse::FromOrderedSet__

  ::Skylab::MetaHell::TestSupport::Parse[ self ]

  include Constants

  extend TestSupport_::Quickie

  MetaHell_ = MetaHell_

  Sandboxer = TestSupport_::Sandbox::Spawner.new

  describe "[mh] Parse::FromOrderedSet__" do
    context "\"from ordered set\" result is array of same length as `set_a`." do
      Sandbox_1 = Sandboxer.spawn
      before :all do
        Sandbox_1.with self
        module Sandbox_1
          PARSER = MetaHell_::Parse.via_ordered_set.curry[
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
