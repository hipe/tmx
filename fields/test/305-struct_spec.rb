require_relative 'test-support'

module Skylab::Fields::TestSupport

  describe "[fi] attributes - struct" do

    TS_[ self ]
    use :memoizer_methods

    context "make a basic struct class with a list of member names (like ::Struct)" do

      before :all do
        X_sct_Foo = Home_.const_get( :Struct, false ).new :nerp
      end

      it "build an instance with `new`, by default the member is nil (like ::Struct)" do
        X_sct_Foo.new.nerp.should eql nil
      end

      it "arguments passed to `new` will become the member values" do
        ( X_sct_Foo.new( :bleep ).nerp ).should eql :bleep
      end

      it "`[]` is effectively an alias for `new`" do
        ( X_sct_Foo[ :fazzle ].nerp ).should eql :fazzle
      end

      it "with an instance you can set (mutate) the value of a member with '='" do
        foo = X_sct_Foo.new
        foo.nerp = :dango
        foo.nerp.should eql :dango
      end

      it "`members` as a class method works like in ::Struct" do
        X_sct_Foo.members.should eql [ :nerp ]
      end

      it "`members` as an instance method does the same" do
        X_sct_Foo.new.members.should eql [ :nerp ]
      end
    end
  end
end
