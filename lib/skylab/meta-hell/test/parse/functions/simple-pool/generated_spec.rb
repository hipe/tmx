require_relative '../../test-support'

module Skylab::MetaHell::TestSupport::Parse

  describe "[mh] Parse::Via_ordered_set__", wip: true do

    context "with an ordered set parser (built from a list of arbitrary procs)" do

      before :all do
        PARSER = Subject_[].via_ordered_set.curry_with(
          :argv_streams, [
            -> args { args.shift if args.first =~ /bill/i },
            -> args { if :hi == args.first then args.shift and :hello end } ] )
      end
      it "result array is in order of \"grammar\", not of elements in argv" do
        argv = [ :hi, 'BILLY', 'bob' ]
        one, two = PARSER.call argv
        one.should eql 'BILLY'
        two.should eql :hello
        argv.should eql [ 'bob' ]
      end
      it "cannot fail (if `set_a` is array of monadic functions and `argv` is ary)" do
        argv = [ :nope ]
        res = PARSER.call argv
        res.should eql [ nil, nil ]
        argv.should eql [ :nope ]
      end
      it "an unparsable element will \"mask\" subsequent would-be parsables" do
        argv = [ :nope, 'BILLY', :hi ]
        res = PARSER.call argv
        res.should eql [ nil, nil ]
        argv.length.should eql 3
      end
    end
  end
end
