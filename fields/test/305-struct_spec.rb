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
        expect( X_sct_Foo.new.nerp ).to eql nil
      end

      it "arguments passed to `new` will become the member values" do
        expect( ( X_sct_Foo.new( :bleep ).nerp ) ).to eql :bleep
      end

      it "`[]` is effectively an alias for `new`" do
        expect( ( X_sct_Foo[ :fazzle ].nerp ) ).to eql :fazzle
      end

      it "with an instance you can set (mutate) the value of a member with '='" do
        foo = X_sct_Foo.new
        foo.nerp = :dango
        expect( foo.nerp ).to eql :dango
      end

      it "`members` as a class method works like in ::Struct" do
        expect( X_sct_Foo.members ).to eql [ :nerp ]
      end

      it "`members` as an instance method does the same" do
        expect( X_sct_Foo.new.members ).to eql [ :nerp ]
      end
    end
  end
end
