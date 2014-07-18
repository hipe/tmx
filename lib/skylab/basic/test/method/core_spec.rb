require_relative 'test-support'

module Skylab::Basic::TestSupport::Method

  describe "[ba] Method" do
    context "a method curry binds arguments to a bound method" do
      Sandbox_1 = Sandboxer.spawn
      it "like so" do
        Sandbox_1.with self
        module Sandbox_1
          class Foo
            def bar a, b
              "ok:#{a}#{b}"
            end
          end

          foo = Foo.new
          mc = Basic::Method::Curry.new foo.method(:bar), [ 'yes', 'sir' ]
          r = mc.receiver.send mc.method_name, * mc.arguments
          r.should eql( "ok:yessir" )
        end
      end
    end
    context "you can validate your argument arity before the call" do
      Sandbox_2 = Sandboxer.spawn
      it "like so" do
        Sandbox_2.with self
        module Sandbox_2
          class Foo
            def bar x, y=nil
              [ x, y ]
            end
          end

          foo = Foo.new

          p = -> *a do
            mc = Basic::Method::Curry.new foo.method(:bar), a
            errmsg = nil
            mc.validate_arity do |o|
              errmsg = "no: #{ o.actual } for #{ o.expected }"
            end
            if errmsg then errmsg else
              mc.receiver.send mc.method_name, * mc.arguments
            end
          end

          p[ 1, 2, 3 ].should eql( "no: 3 for 1..2" )
          p[ 1, 2 ].should eql( [ 1, 2 ] )
          p[ 1 ].should eql( [ 1, nil ] )
          p[ ].should eql( "no: 0 for 1..2" )
        end
      end
    end
  end
end
