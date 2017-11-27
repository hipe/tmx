require_relative '../test-support'

module Skylab::Basic::TestSupport
  # -
    describe "[ba] list - lowest (etc)" do

      it "that lets you `each_pair` over them" do

        _ea = Home_::List.build_each_pairable_via_even_iambic [ :a, :b, :c, :d ]

        _a = _ea.enum_for( :each_pair ).to_a

        expect( ( ::Hash[ _a ] ) ).to eql ( { a: :b, c: :d } )
      end

      it "none (left)" do
        _a = _against EMPTY_A_, %i( a )
        _a and fail
      end

      it "none (right)" do
        _a = _against %i( a ), EMPTY_A_
        _a and fail
      end

      it "none (both)" do
        _a = _against EMPTY_A_, EMPTY_A_
        _a and fail
      end

      it "right full match 2 from end" do
        _a = _against %i( a b c ), %i( b c )
        expect( _a ).to eql [ 1, 0 ]
      end

      it "partial match 2 from end" do
        _a = _against %i( a b c d ), %i( x k c d )
        expect( _a ).to eql [ 2, 2 ]
      end

      it "full (1)" do
        _a = _against %i( a ), %i( a )
        expect( _a ).to eql [ 0, 0 ]
      end

      it "full (2)" do
        _a = _against %i( a, b ), %i( a b )
        expect( _a ).to eql [ 1, 1 ]
      end

      def _against a1, a2
        Home_::List.lowest_indexes_of_tail_anchored_common_element a1, a2
      end
    end
  # -
end
