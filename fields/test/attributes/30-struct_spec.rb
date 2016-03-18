require_relative '../test-support'

module Skylab::Fields::TestSupport  # #[#ts-046] (used to be generated)

  describe "[fi] attributes - struct" do

    TS_[ self ]
    use :memoizer_methods

     context "make a basic struct class with a list of member names (like ::Struct)" do

      shared_subject :_class do

        cls = _subject_module.new :nerp
        X_Attrs_Stct_A = cls
        cls
      end

      it "build an instance with `new`, by default the member is nil (like ::Struct)" do
        _class.new.nerp.should eql nil
      end

      it "arguments passed to `new` will become the member values" do
        _class.new( :bleep ).nerp.should eql :bleep
      end

      it "`[]` is effectively an alias for `new`" do
        _class[ :fazzle ].nerp.should eql :fazzle
      end

      it "with an instance you can set (mutate) the value of a member with '='" do
        foo = _class.new
        foo.nerp = :dango
        foo.nerp.should eql :dango
      end

      it "`members` as a class method works like in ::Struct" do
        _class.members.should eql [ :nerp ]
      end

      it "`members` as an instance method does the same" do
        _class.new.members.should eql [ :nerp ]
      end
    end

    def _subject_module
      Home_::Attributes.struct_class
    end
  end
end
