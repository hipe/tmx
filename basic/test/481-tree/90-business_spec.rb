require_relative '../test-support'

module Skylab::Basic::TestSupport

  describe "[ba] tree - business" do

    TS_[ self ]

    subject = -> do
      Home_::Tree::Business
    end

    Home_.lib_.parse_lib::DSL_DSL.enhance self do
      memoize :_with_class, :_class
    end

    context "a produced subclass with one field" do

      _with_class do

        T_B_1 = subject[].new :foo
      end

      it "trying to pass too many args - arg error" do

        cls = _class
        begin
          cls.new :one, :two
        rescue Home_::ArgumentError => e
        end
        expect( e.message ).to match %r(\bwrong number.+\(2 for 1\))
      end

      it "trying to pass too few args - ok, you get nil (and reader)" do
        me = _class.new
        expect( me.foo ).to eql( nil )
      end
    end

      it "unlike struct, it can subclass" do

        T_B_2 = ::Class.new( subject[].new( :foo, :bar ) )

        T_B_3 = T_B_2.subclass :wing, :wang

        kls2 = T_B_3

        expect( kls2.const_get( :BX____ ).a_ ).to eql(

          [ :foo, :bar, :wing, :wang ] )

        o2 = kls2.new 'fOo', 'bAr', 'wIng', 'wAng'

        expect( o2.bar ).to eql 'bAr'

        expect( o2.wang ).to eql 'wAng'
      end
  end
end
