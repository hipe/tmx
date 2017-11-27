require_relative '../test-support'

module Skylab::Common::TestSupport

  describe "[co] box - as" do

    TS_[ self ]
    use :box_support

    context "retrieve" do

      memoize_subject_ do

        bx = subject_.new
        bx.add :one, :One
        bx.add :three, :Three
        bx.add :five, :Five
        bx.algorithms
      end

      it "when you retrieve with |k, x| you get a [k, x] result" do
        expect( subject_.retrieve do | k, v |
          :three == k
        end ).to eql [ :three, :Three ]
      end

      it "when you retrieve with | x \ you get x back" do
        expect( subject_.retrieve do | x |
          :Five == x
        end ).to eql :Five
      end

      it "can be used like a complicated fetch" do

        k, x = subject_.retrieve -> k_, v_ { :three == k_ }

        expect( k ).to eql :three
        expect( x ).to eql :Three
      end

      it "the `else` proc works as proc" do

        expect( subject_.retrieve( -> x { :NotThere == x }, -> { :alternate } ) ).to eql :alternate
      end

      it "the `else` proc works as block" do
        expect( ( subject_.retrieve -> x { false } do :no end ) ).to eql :no
      end

      it "errmsg" do

        _rx = /\bvalue not found matching #<Proc@#{ ::Regexp.escape __FILE__ }:\d+>\z/
        expect( -> do
          subject_.retrieve -> x { false }
        end ).to raise_error ::KeyError, _rx
      end
    end

    it "to_hash" do

      expect( subject_with_entries_( :a, :A, :b, :B ).
        algorithms.to_hash ).to eql a: :A, b: :B
    end

    it "mutate_by_sorting_name_by" do

      bx = subject_with_entries_ :z, :Z, :x, :X, :y, :Y
      desired_order = [ :x, :z, :y ]
      bx.algorithms.mutate_by_sorting_name_by( & desired_order.method( :index ) )
      expect( bx.instance_variable_get( :@a ) ).to eql desired_order
    end

    it "clear" do

      bx = subject_with_entries_ :a, :b
      expect( bx.length ).to eql 1
      expect( bx.algorithms.clear ).to be_nil
      expect( bx.length ).to be_zero
    end
  end
end
