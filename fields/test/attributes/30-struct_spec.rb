require_relative 'test-support'

module Skylab::Basic::TestSupport::Struct

  ::Skylab::Basic::TestSupport[ self ]

  include Constants

  extend TestSupport_::Quickie

  Home_ = Home_

  Subject_ = -> * x_a, & p do
    if x_a.length.nonzero? || p
      Home_::Struct[ * x_a, & p ]
    else
      Home_::Struct
    end
  end

  describe "[ba] Struct" do

    context "make a basic struct class with a list of member names (like ::Struct)" do

      before :all do
        Foo = Home_::Struct.new :nerp
      end
      it "build an instance with `new`, by default the member is nil (like ::Struct)" do
        Foo.new.nerp.should eql nil
      end
      it "arguments passed to `new` will become the member values" do
        Foo.new( :bleep ).nerp.should eql :bleep
      end
      it "`[]` is effectively an alias for `new`" do
        Foo[ :fazzle ].nerp.should eql :fazzle
      end
      it "with an instance you can set (mutate) the value of a member with '='" do
        foo = Foo.new
        foo.nerp = :dango
        foo.nerp.should eql :dango
      end
      it "`members` as a class method works like in ::Struct" do
        Foo.members.should eql [ :nerp ]
      end
      it "`members` as an instance method does the same" do
        Foo.new.members.should eql [ :nerp ]
      end
    end
  end
end
