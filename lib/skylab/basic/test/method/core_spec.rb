require_relative 'test-support'

module Skylab::Basic::TestSupport::Method

  describe "[ba] Method" do

    it "a method curry (like that other thing) binds arguments to a bound method call" do
      class Foo
        def bar a, b
          "ok:#{a}#{b}"
        end
      end

      foo = Foo.new
      mc = Basic_::Method.curry.new foo.method(:bar), [ 'yes', 'sir' ]
      x = mc.receiver.send mc.method_name, * mc.arguments
      x.should eql "ok:yessir"
    end
    it "you can validate your argument arity before the call" do
      class Bar
        def bar x, y=nil
          [ x, y ]
        end
      end

      foo = Bar.new

      p = -> *a do
        mc = Basic_::Method.curry.new foo.method(:bar), a
        errmsg = nil
        mc.validate_arity do |o|
          errmsg = "no: #{ o.actual } for #{ o.expected }"
        end
        if errmsg then errmsg else
          mc.receiver.send mc.method_name, * mc.arguments
        end
      end

      p[ 1, 2, 3 ].should eql "no: 3 for 1..2"
      p[ 1, 2 ].should eql [ 1, 2 ]
      p[ 1 ].should eql [ 1, nil ]
      p[ ].should eql "no: 0 for 1..2"
    end
  end
end
