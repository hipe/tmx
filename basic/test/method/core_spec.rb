require_relative '../test-support'

module Skylab::Basic::TestSupport

  describe "[ba] Method" do

    extend TS_
    use :memoizer_methods

    context "a method curry (like that other thing) binds arguments to a bound method call" do

      before :all do
        class X_m_c_Foo
          def bar a, b
            "ok:#{a}#{b}"
          end
        end
      end

      shared_subject :mc do

        _foo = X_m_c_Foo.new

        Home_::Method.curry.new _foo.method( :bar ), [ 'yes', 'sir' ]
      end

      it "parts of a method call" do
        x = mc.receiver.send mc.method_name, * mc.arguments
        x.should eql "ok:yessir"
      end
    end

    context "you can validate your argument arity before the call" do

      before :all do
        class X_m_c_Bar
          def bar x, y=nil
            [ x, y ]
          end
        end
      end

      shared_subject :p do

        foo = X_m_c_Bar.new

        p = -> *a do
          mc = Home_::Method.curry.new foo.method(:bar), a
          errmsg = nil
          mc.validate_arity do |o|
            errmsg = "no: #{ o.actual } for #{ o.expected }"
          end
          if errmsg then errmsg else
            mc.receiver.send mc.method_name, * mc.arguments
          end
        end

        p
      end

      it "too many arguments" do
        ( p[ 1, 2, 3 ] ).should eql "no: 3 for 1..2"
      end

      it "the max number of allowed args" do
        ( p[ 1, 2 ] ).should eql [ 1, 2 ]
      end

      it "the min number of allowed args" do
        ( p[ 1 ] ).should eql [ 1, nil ]
      end

      it "not enough arguments" do
        ( p[ ] ).should eql "no: 0 for 1..2"
      end
    end
  end
end
